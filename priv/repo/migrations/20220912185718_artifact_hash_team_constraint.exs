defmodule Turbo.Repo.Migrations.ArtifactHashTeamConstraint do
  use Ecto.Migration

  def change do
    drop unique_index(:artifacts, [:hash])
    create unique_index(:artifacts, [:hash, :team_id])
  end
end
