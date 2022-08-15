defmodule Turbo.Teams do
  import Ecto.Query, warn: false
  alias Turbo.Repo
  alias Turbo.Accounts.User
  alias Turbo.Models.Team

  def change(user) do
    %Team{}
    |> Team.changeset(user)
  end

  @spec create(User.t(), map()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def create(user, attrs) do
    %Team{}
    |> Team.changeset(user, attrs)
    |> Repo.insert()
  end

  def get_all() do
    Team
    |> Repo.all()
  end
end
