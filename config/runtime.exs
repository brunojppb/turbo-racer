import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/turbo start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :turbo, TurboWeb.Endpoint, server: true
end

# S3 uploads config
# If present, it takes over file system uploads for artifacts
if System.get_env("S3_BUCKET_NAME") &&
     System.get_env("S3_ACCESS_KEY_ID") &&
     System.get_env("S3_SECRET_ACCESS_KEY") &&
     System.get_env("S3_HOST") do
  config :turbo, s3_bucket_name: System.get_env("S3_BUCKET_NAME")

  config :ex_aws,
    access_key_id: System.get_env("S3_ACCESS_KEY_ID"),
    secret_access_key: System.get_env("S3_SECRET_ACCESS_KEY"),
    s3: [host: System.get_env("S3_HOST")]

  # Make The S3 implementation active
  config :turbo, :file_store, Turbo.Storage.S3Store
end

# Production-only runtime config that relies on environment variables.
# This file does not get compiled during the release, but is read during app boot
# which allows us to dynamically change values based on the environment.
if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []
  use_db_ssl = System.get_env("USE_DB_SSL") == "1"

  db_ssl_opts =
    if System.get_env("DATABASE_CA_CERT") do
      [
        verify: :verify_peer,
        cacertfile: System.get_env("DATABASE_CA_CERT"),
        verify_fun: &:ssl_verify_hostname.verify_fun/3,
        server_name_indication: String.to_charlist(System.get_env("DATABASE_HOST", ""))
      ]
    else
      []
    end

  config :turbo, Turbo.Repo,
    ssl: use_db_ssl,
    ssl_opts: db_ssl_opts,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")
  scheme = if System.get_env("USE_HTTPS") == "1", do: "https", else: "http"
  # Using 443 as the default port when HTTPS is enabled.
  # Will render full URLs in emails and templates without the port component.
  url_port = if scheme == "https", do: 443, else: port

  config :turbo, TurboWeb.Endpoint,
    url: [host: host, port: url_port, scheme: scheme],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # Oban job scheduler/processing
  three_days = 60 * 60 * 24 * 3

  config :turbo, Oban,
    repo: Turbo.Repo,
    plugins: [
      # Hold Oban jobs for 72h so we can debug in case of any issues.
      {Oban.Plugins.Pruner, max_age: three_days},
      {Oban.Plugins.Cron,
       crontab: [
         {
           # Execute the cleanup job once a day
           "0 0 * * *",
           Turbo.Worker.ArtifactBusting,
           args: %{
             days_from_now: String.to_integer(System.get_env("ARTIFACT_BUSTING_IN_DAYS") || "90")
           }
         }
       ]}
    ],
    queues: [
      default: 10,
      artifact_busting: 1
    ]

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :turbo, Turbo.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
