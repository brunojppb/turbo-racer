defmodule TurboWeb.UserRegistrationControllerTest do
  use TurboWeb.ConnCase

  import Turbo.AccountsFixtures
  alias Turbo.Settings.SettingsContext

  setup do
    on_exit(fn ->
      reset_app_settings()
    end)
  end

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Create Your Account</h1>"
      assert response =~ "Log in</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end

    test "redirects to login when registration is disabled", %{conn: conn} do
      SettingsContext.update_app_access(%{"can_signup" => false, "can_manage_tokens" => true})
      conn = get(conn, Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)

      assert Phoenix.Flash.get(conn, :error) =~
               "Creating accounts is disabled for this instance. Please, contact an admin."
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => valid_user_attributes(email: email)
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      assert "/teams" = redir_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redir_path)
      response = html_response(conn, 200)
      assert response =~ "Add new team</a>"
      assert response =~ "Logout</a>"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Create Your Account</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
