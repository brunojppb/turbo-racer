defmodule Turbo.Teams do
  import Ecto.Query, warn: false
  alias Turbo.Repo
  alias Turbo.Accounts.User
  alias Turbo.Models.Team

  @spec create(User.t(), map()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def create(user, attrs) do
    %Team{}
    |> Team.changeset(user, attrs)
    |> Repo.insert()
  end
end
