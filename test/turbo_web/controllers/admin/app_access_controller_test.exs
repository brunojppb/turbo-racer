defmodule TurboWeb.Controllers.Admin.AppAccessControllerTest do
  use TurboWeb.ConnCase

  setup :register_and_log_in_admin
  alias Turbo.Settings.SettingsContext

  setup do
    on_exit(fn ->
      reset_app_settings()
    end)
  end

  describe "GET /admin/settings/access" do
    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.app_access_path(conn, :index))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end

    test "redirect if logged in user isn't admin", %{conn: conn} do
      %{conn: user_conn} = register_and_log_in_user(%{conn: conn})
      user_conn = get(user_conn, Routes.app_access_path(user_conn, :index))
      assert redirected_to(user_conn) == Routes.page_path(user_conn, :index)

      assert Phoenix.Flash.get(user_conn.assigns.flash, :error) =~
               "You are not allowed to access this route"
    end

    test "renders app access page for admin users", %{conn: conn} do
      conn = get(conn, Routes.app_access_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "App Access</a>"
      assert response =~ "Allow users to to manage teams and tokens</span>"
      assert response =~ "Allow users to create accounts</span>"
    end
  end

  describe "PUT /admin/settings/access (app access form)" do
    test "disable user signup", %{conn: conn} do
      app_settings_conn =
        put(conn, Routes.app_access_path(conn, :update), %{
          "app_access" => %{
            "can_manage_tokens" => "true",
            "can_signup" => "false"
          }
        })

      assert redirected_to(app_settings_conn) == Routes.app_access_path(conn, :index)
      assert Phoenix.Flash.get(app_settings_conn.assigns.flash, :info) =~ "App Access updated"
      app_access = SettingsContext.get_app_access()
      assert app_access.can_manage_tokens
      refute app_access.can_signup
    end
  end
end
