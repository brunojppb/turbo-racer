defmodule Turbo.Settings.SettingsContext do
  alias Turbo.Models.AppSettings
  alias Turbo.Settings.AppAccess
  alias Turbo.Repo
  require Logger
  import Ecto.Changeset

  @access_settings_key "app_access"

  @spec get_app_access() :: AppAccess.t()
  def get_app_access() do
    AppSettings
    |> Repo.get_by!(key: @access_settings_key)
    |> AppAccess.new()
  end

  @spec app_access_changeset(attrs :: map()) :: Ecto.Changeset.t()
  def app_access_changeset(attrs \\ %{}) do
    AppSettings
    |> Repo.get_by!(key: @access_settings_key)
    |> AppAccess.new()
    |> AppAccess.changeset(attrs)
  end

  @doc """
  Update app settings using a schemaless struct `AppAccess`
  """
  @spec update_app_access(map()) :: Turbo.result(AppAccess.t(), Ecto.Changeset.t())
  def update_app_access(attrs \\ %{}) do
    app_access_changeset(attrs)
    |> case do
      changeset when changeset.valid? ->
        apply_changes(changeset)
        |> save_app_access()

      changeset ->
        {:error, changeset}
    end
  end

  # Upsert the "app_access" settings, always overwriting
  # The existing settings in the DB.
  @spec save_app_access(app_access :: AppAccess.t()) :: Turbo.result(AppAccess.t())
  defp save_app_access(%AppAccess{} = app_access) do
    %AppSettings{}
    |> AppSettings.changeset(%{
      key: @access_settings_key,
      value: Map.from_struct(app_access)
    })
    |> Repo.insert(
      on_conflict: [set: [value: Map.from_struct(app_access)]],
      conflict_target: :key,
      returning: true
    )
    |> case do
      {:ok, app_settings} ->
        {:ok, AppAccess.new(app_settings)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
