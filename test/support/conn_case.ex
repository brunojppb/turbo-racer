defmodule TurboWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use TurboWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import TurboWeb.ConnCase

      alias TurboWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint TurboWeb.Endpoint
    end
  end

  setup tags do
    Turbo.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = Turbo.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Setup helper that registers and logs in admin users

      setup :register_and_log_in_admin

  It stores an updated connection and a registered admin user in the
  test context.
  """
  def register_and_log_in_admin(%{conn: conn}) do
    user = Turbo.AccountsFixtures.admin_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Turbo.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  @doc """
  Reset app settings to enable signup and token management
  """
  def reset_app_settings() do
    Turbo.Settings.SettingsContext.update_app_access(%{
      "can_signup" => "true",
      "can_manage_tokens" => "true"
    })
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection, a team and a Bearer token
  as part of the headers for artifacts authentication.
  """
  def create_and_log_in_team(%{conn: conn}, team_name \\ "turbo-racer") do
    user = Turbo.AccountsFixtures.user_fixture()
    {team, token} = Turbo.TeamsFixtures.team_and_token_fixtures(user, %{name: team_name})

    conn =
      conn
      |> Plug.Conn.assign(:team, team)
      |> Plug.Conn.put_req_header("authorization", "Bearer " <> token.token)

    %{conn: conn, team: team, token: token, user: user}
  end
end
