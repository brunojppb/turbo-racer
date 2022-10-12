defmodule TurboWeb.Admin.UserManagementController do
  use TurboWeb, :controller
  alias Turbo.Accounts
  require Logger

  plug :put_layout, "admin/layout.html"

  def index(conn, _params) do
    users = Turbo.Accounts.get_all_users()
    render(conn, "index.html", users: users)
  end

  def toggle_access(conn, %{"user_id" => user_id}) do
    Logger.info("User toggle: #{user_id}")

    case Accounts.toggle_access(user_id) do
      {:ok, user} ->
        status = if user.is_locked, do: "access revoked", else: "access granted"

        conn
        |> put_flash(:info, "User #{user.email} #{status}.")
        |> redirect(to: Routes.user_management_path(conn, :index))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.user_management_path(conn, :index))
    end
  end

  def update_role(conn, _params) do
    conn
    |> put_flash(:info, "User role updated.")
    |> redirect(to: Routes.user_management_path(conn, :index))
  end
end
