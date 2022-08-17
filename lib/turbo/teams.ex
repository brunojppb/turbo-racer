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

  def delete(team_id) do
    {deleted_rows, _} = from(t in Team, where: t.id == ^team_id) |> Repo.delete_all()

    if deleted_rows > 0 do
      {:ok, team_id}
    else
      {:error, "Could not delete team #{team_id}"}
    end
  end

  def get_all() do
    Team
    |> Repo.all()
  end
end
