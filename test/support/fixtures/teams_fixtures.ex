defmodule Turbo.TeamsFixtures do
  @moduledoc """
  Test helpers for creating entities via the
  `Turbo.Teams` context.
  """

  alias Turbo.Teams

  def team_fixture(user, attrs \\ %{}) do
    {:ok, team} = Teams.create(user, attrs)
    team
  end

  def token_fixture(team_id, user) do
    {:ok, token} = Teams.generate_token(team_id, user)
    token
  end

  def team_and_token_fixtures(user, attrs \\ %{}) do
    team = team_fixture(user, attrs)
    token = token_fixture(team.id, user)
    {team, token}
  end
end
