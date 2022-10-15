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
    current_user = conn.assigns[:current_user]

    int_user_id = if is_binary(user_id), do: String.to_integer(user_id), else: user_id

    if int_user_id == current_user.id do
      halt_current_user_lock(conn)
    else
      toggle_user_access(conn, current_user, user_id)
    end
  end

  def update_role(conn, _params) do
    conn
    |> put_flash(:info, "User role updated.")
    |> redirect(to: Routes.user_management_path(conn, :index))
  end

  # This smells a bit. Would be better to have lock and unlock functions
  # that are distinctively separated from each other.
  # But this is simple enough for now.
  defp toggle_user_access(conn, admin_user, user_id) do
    case Accounts.toggle_access(user_id) do
      {:ok, user} ->
        status = if user.is_locked, do: "access revoked", else: "access granted"

        Logger.info("User #{user.id} got its #{status} by admin #{admin_user.id}")

        conn
        |> put_flash(:info, "User #{user.email} #{status}.")
        |> redirect(to: Routes.user_management_path(conn, :index))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.user_management_path(conn, :index))
    end
  end

  defp halt_current_user_lock(conn) do
    conn
    |> put_flash(
      :error,
      "To avoid lockouts, you cannot update your own account. Please contact another admin."
    )
    |> redirect(to: Routes.user_management_path(conn, :index))
  end
end
