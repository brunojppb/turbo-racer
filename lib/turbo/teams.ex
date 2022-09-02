defmodule Turbo.Teams do
  import Ecto.Query
  alias Turbo.Repo
  alias Turbo.Accounts.User
  alias Turbo.Models.{Team, TeamToken}
  alias Turbo.Artifacts

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

  @spec delete(team_id :: integer() | String.t()) :: Turbo.result(team_id :: integer())
  def delete(team_id) do
    Artifacts.delete_all_from_team(team_id)
    |> delete_team(team_id)
  end

  defp delete_team(:ok, team_id) do
    {rows_deleted, _} = from(t in Team, where: t.id == ^team_id) |> Repo.delete_all()

    if rows_deleted > 0 do
      {:ok, team_id}
    else
      {:error, "Could not delete team #{team_id}"}
    end
  end

  defp delete_team({:error, reason}, _team_id), do: {:error, reason}

  @spec get(team_id :: integer() | binary()) :: Team.t() | nil
  def get(team_id) do
    Team
    |> Repo.get(team_id)
  end

  @spec get_all() :: list(Team.t())
  def get_all() do
    Team
    |> Repo.all()
  end

  @spec get_team_tokens(team_id :: integer()) ::
          {Team.t(), list(TeamToken.t())} | {nil, list(TeamToken.t())}
  def get_team_tokens(team_id) do
    tokens_query = from t in TeamToken, where: t.team_id == ^team_id
    team = Team |> Repo.get(team_id)
    tokens = tokens_query |> Repo.all()

    {team, tokens}
  end

  @spec delete_token(token_id :: binary()) :: Turbo.result(binary())
  def delete_token(token_id) do
    {rows_deleted, _} = from(t in TeamToken, where: t.id == ^token_id) |> Repo.delete_all()

    if rows_deleted > 0 do
      {:ok, token_id}
    else
      {:error, "Could not delete token with ID #{token_id}"}
    end
  end

  def get_team_by_token(token) do
    token_query = from t in TeamToken, where: t.token == ^token

    with [team_token] <- Repo.all(token_query),
         [team] <- Repo.all(from(t in Team, where: t.id == ^team_token.team_id)) do
      {:ok, team}
    else
      _ -> {:error, "Invalid token"}
    end
  end

  @doc """
  Generate a new token for the given team.
  User is stored for future audits.
  """
  @spec generate_token(team_id :: integer(), user :: User.t()) ::
          {:ok, TeamToken.t()} | {:error, Ecto.Changeset.t()}
  def generate_token(team_id, user) do
    team = Team |> Repo.get(team_id)

    token = Turbo.generate_rand_token()

    %TeamToken{}
    |> TeamToken.changeset(team, user, %{token: token})
    |> Repo.insert()
  end
end
