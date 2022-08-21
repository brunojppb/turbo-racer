# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :turbo,
  ecto_repos: [Turbo.Repo]

# Configures the endpoint
config :turbo, TurboWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: TurboWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Turbo.PubSub,
  live_view: [signing_salt: "S3zO00N+"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :turbo, Turbo.Mailer, adapter: Swoosh.Adapters.Local

# by default, use the priv directory for artifact uploads
# overwrite this in other environments if you want to have
# to use /var/turbo_artifacts instead
config :turbo, :use_priv_for_artifacts, true

# Oban job scheduler/processing
three_days = 60 * 60 * 24 * 3

config :turbo, Oban,
  repo: Turbo.Repo,
  plugins: [
    # Hold Oban jobs for 72h so we can debug in case of any issues.
    {Oban.Plugins.Pruner, max_age: three_days}
  ],
  queues: [
    default: 10,
    artifact_busting: 1
  ]

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
