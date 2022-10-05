defmodule Turbo.Repo.Migrations.AddAppSettings do
  use Ecto.Migration
  require Logger

  def up do
    create table(:app_settings) do
      add :key, :string, null: false
      add :value, :map, default: %{}, null: false
      timestamps()
    end

    create unique_index(:app_settings, [:key])

    # A GIN index will allow us to perform queries in the jsonb field more efficiently.
    execute("CREATE INDEX app_settings_value_idx ON app_settings USING GIN(value)")

    # Dead-simple role column to control app settings.
    # I do not intend to make this a full-blown role-based authorization system...
    alter table(:users) do
      add :role, :string, null: false, default: "user"
    end

    execute(fn ->
      result = repo().query!("SELECT id from users ORDER BY id ASC LIMIT 1")

      case result.rows do
        # There is at least one user already in the DB
        # So we will make it the admin user and preserve the current settings
        [[id]] ->
          Logger.info("User with ID=#{inspect(id)} exists. Making it admin...")
          repo().query!("UPDATE users SET role = 'admin' WHERE id = #{id}")

        # First time settings up Turbo Racer or users table is still empty.
        # Defer admin setup for when they signup
        [] ->
          Logger.info("No existing users. Skipping admin user updates...")
      end

      # Always have an "app_access" entry in the DB by default to drive
      # The app access and account creation. All active by default so it's
      # backwards compatible with older versions of Turbo Racer
      repo().query!("""
      INSERT INTO app_settings (key, value, inserted_at, updated_at)
      VALUES (
        'app_access',
        '{ "can_manage_tokens": true, "can_signup": true }'::jsonb,
        NOW(),
        NOW()
      );
      """)
    end)
  end

  def down do
    alter table(:users) do
      remove :role
    end

    # Dropping the table will also automatically drop
    # any custom index added to it like `app_settings_value_idx`
    drop table(:app_settings)
  end
end
