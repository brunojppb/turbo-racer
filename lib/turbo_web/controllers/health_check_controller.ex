defmodule TurboWeb.HealthCheckController do
  use TurboWeb, :controller

  alias Turbo.Settings.SettingsContext

  def index(conn, _params) do
    # Just force a dummy DB query/cache read.
    # If that doesn't crash, we can assume the system is up
    _ = SettingsContext.get_app_access()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{status: "ok"}))
  end
end
