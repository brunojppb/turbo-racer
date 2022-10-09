defmodule TurboWeb.UserRegistrationController do
  use TurboWeb, :controller

  alias Turbo.Accounts
  alias Turbo.Accounts.User
  alias TurboWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    # This is a bit of a hack, but whenever booting up the system
    # for the first time, the first user to signup will be an admin
    # so they can toggle admin settings from the start.
    registration_fn =
      if Accounts.is_admin_present?(),
        do: &Accounts.register_user/1,
        else: &Accounts.register_admin/1

    case registration_fn.(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
