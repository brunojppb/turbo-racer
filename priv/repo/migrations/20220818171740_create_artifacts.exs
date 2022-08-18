defmodule Turbo.Repo.Migrations.CreateArtifacts do
  use Ecto.Migration

  def change do
    create table(:artifacts) do
      add :hash, :string, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:artifacts, [:hash])
  end
end
