defmodule Turbo.ArtifactsFixtures do
  @moduledoc """
  Test helpers for creating entities via the
  `Turbo.Artifacts` context.
  """

  import Ecto.Changeset
  alias Turbo.Models.Artifact
  alias Turbo.Artifacts
  alias Turbo.Repo

  def artifact_fixture(hash, team) do
    {:ok, artifact} = Artifacts.create("some_binary_encoded_data", hash, team)
    artifact
  end

  def new_artifact_fixture(hash) do
    user = Turbo.AccountsFixtures.user_fixture()
    team = Turbo.TeamsFixtures.team_fixture(user, %{name: "new-team"})
    {:ok, artifact} = Artifacts.create("some_binary_data", hash, team)
    artifact
  end

  def stale_artifact_fixture(hash, inserted_at) do
    user = Turbo.AccountsFixtures.user_fixture()
    team = Turbo.TeamsFixtures.team_fixture(user, %{name: "old-team"})
    {:ok, artifact} = Artifacts.create("some_binary_data", hash, team)

    artifact
    |> Artifact.changeset(team, %{hash: hash})
    |> put_change(:inserted_at, inserted_at)
    |> Repo.update!()
  end

  def clean_up_artifact(hash, team_id) do
    {:ok, _} = Artifacts.delete(hash, team_id)
  end

  def maybe_clean_up_artifact(hash, team_id) do
    Artifacts.delete(hash, team_id)
  end
end
