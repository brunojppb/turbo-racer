defmodule Turbo.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false
      add :user_id, references(:users), null: false
      timestamps()
    end

    create unique_index(:teams, [:name])
  end
end
