defmodule Turbo.Repo.Migrations.CreateTeamTokens do
  use Ecto.Migration

  def change do
    create table(:team_tokens) do
      add :token, :string, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :user_id, references(:users), null: false
      timestamps()
    end

    create unique_index(:team_tokens, [:token])
  end
end
