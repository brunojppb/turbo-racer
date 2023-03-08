defmodule TurboWeb.Controllers.Admin.UserManagementControllerTest do
  use TurboWeb.ConnCase
  import Turbo.AccountsFixtures

  setup :register_and_log_in_admin

  describe "GET /admin/settings/users" do
    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.user_management_path(conn, :index))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end

    test "renders Users page for admin users", %{conn: conn} do
      conn = get(conn, Routes.user_management_path(conn, :index))
      user = conn.assigns[:current_user]
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ "Update role"
    end
  end

  describe "POST /admin/users/access (user access form)" do
    test "manage user login access", %{conn: conn} do
      common_user = user_fixture()

      user_access_conn =
        post(conn, Routes.user_management_path(conn, :toggle_access), %{
          "user_id" => common_user.id
        })

      assert redirected_to(user_access_conn) ==
               Routes.user_management_path(user_access_conn, :index)

      assert Phoenix.Flash.get(user_access_conn.assigns.flash, :info) =~
               "#{common_user.email} access revoked."

      user_access_conn =
        post(conn, Routes.user_management_path(conn, :toggle_access), %{
          "user_id" => common_user.id
        })

      assert redirected_to(user_access_conn) ==
               Routes.user_management_path(user_access_conn, :index)

      assert Phoenix.Flash.get(user_access_conn.assigns.flash, :info) =~
               "#{common_user.email} access granted."
    end

    test "cannot lock its own admin account", %{conn: conn, user: admin} do
      user_access_conn =
        post(conn, Routes.user_management_path(conn, :toggle_access), %{
          "user_id" => admin.id
        })

      assert redirected_to(user_access_conn) ==
               Routes.user_management_path(user_access_conn, :index)

      assert Phoenix.Flash.get(user_access_conn.assigns.flash, :error) =~
               "To avoid lockouts, you cannot update your own account. Please contact another admin."
    end
  end

  describe "POST /admin/users/role (user role form)" do
    test "update user role", %{conn: conn} do
      common_user = user_fixture()

      user_role_conn =
        post(conn, Routes.user_management_path(conn, :update_role), %{
          "user_id" => common_user.id,
          "role" => "admin"
        })

      assert redirected_to(user_role_conn) == Routes.user_management_path(user_role_conn, :index)

      assert Phoenix.Flash.get(user_role_conn.assigns.flash, :info) =~
               "#{common_user.email} role updated."
    end

    test "cannot change its own role as an admin", %{conn: conn, user: admin} do
      user_role_conn =
        post(conn, Routes.user_management_path(conn, :update_role), %{
          "user_id" => admin.id,
          "role" => "user"
        })

      assert redirected_to(user_role_conn) == Routes.user_management_path(user_role_conn, :index)

      assert Phoenix.Flash.get(user_role_conn.assigns.flash, :error) =~
               "To avoid lockouts, you cannot update your own account. Please contact another admin."
    end
  end
end
