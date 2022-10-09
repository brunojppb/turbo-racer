defmodule Turbo.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Turbo.Accounts` context.
  """

  def unique_user_email, do: "user#{Ecto.UUID.generate()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Turbo.Accounts.register_user()

    user
  end

  def admin_fixture(attrs \\ %{}) do
    {:ok, admin_user} =
      attrs
      |> valid_user_attributes()
      |> Turbo.Accounts.register_admin()

    admin_user
  end

  import Ecto.Query
  alias Turbo.Repo

  def clean_up_admins() do
    query = from u in Turbo.Accounts.User, where: u.role == "admin"
    Repo.delete_all(query)
    Turbo.Accounts.update_has_admin_cache(false)
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
