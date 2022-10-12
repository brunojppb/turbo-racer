defmodule Turbo.Repo.Migrations.AddUserLock do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :is_locked, :boolean, null: false, default: false
    end
  end

  def down do
    alter table(:users) do
      remove :is_locked
    end
  end
end
