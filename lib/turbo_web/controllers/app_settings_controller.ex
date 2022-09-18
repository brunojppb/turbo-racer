defmodule TurboWeb.AppSettingsController do
  use TurboWeb, :controller
  alias Turbo.Settings.SettingsContext
  require Logger

  def index(conn, _params) do
    app_access = SettingsContext.app_access_changeset()
    render(conn, "index.html", changeset: app_access)
  end

  def update(conn, %{"app_access" => app_access_params}) do
    case SettingsContext.update_app_access(app_access_params) do
      {:ok, _app_access} ->
        conn
        |> put_flash(:info, "App Access updated successfully")
        |> redirect(to: Routes.app_settings_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Oops... Something went wrong. Please try again")
        |> redirect(to: Routes.app_settings_path(conn, :index))
    end
  end
end
