defmodule Turbo.SettingsManager do
  alias Turbo.Models.AppSettings
  alias Turbo.Repo

  defmodule AppAccess do
    @moduledoc """
    Read-only App access settings where admins can define
    whether users can:
    - Allow users to login and manage tokens
    - Create new accounts
    """
    defstruct can_login: false, can_signup: false

    @type t :: %__MODULE__{
            can_login: boolean(),
            can_signup: boolean()
          }

    @spec new(settings :: AppSettings.t()) :: __MODULE__.t()
    def new(settings) do
      %__MODULE__{
        can_login: settings.value.can_login,
        can_signup: settings.value.can_signup
      }
    end
  end

  @access_settings_key "app_access"

  @spec update_app_access(map()) :: Turbo.result(AppAccess.t())
  def update_app_access(%{can_login: _can_login, can_signup: _can_signup} = value) do
    %AppSettings{}
    |> AppSettings.changeset(%{
      key: @access_settings_key,
      value: value
    })
    |> Repo.insert(
      on_conflict: [set: [value: value]],
      conflict_target: :key,
      returning: true
    )
    |> case do
      {:ok, app_settings} ->
        AppAccess.new(app_settings)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @spec get_app_access() :: AppAccess.t()
  def get_app_access() do
    AppSettings
    |> Repo.get_by!(key: @access_settings_key)
    |> AppAccess.new()
  end
end
