defmodule Turbo.Settings.AppAccess do
  @moduledoc """
  Read-only, Schemaless App access settings where admins can define
  whether users can:
  - Login and manage tokens
  - Create new accounts
  """
  alias Turbo.Models.AppSettings
  import Ecto.Changeset

  defstruct can_manage_tokens: true, can_signup: true

  @type t :: %__MODULE__{
          can_manage_tokens: boolean(),
          can_signup: boolean()
        }

  @types %{can_manage_tokens: :boolean, can_signup: :boolean}

  @spec new(settings :: AppSettings.t()) :: __MODULE__.t()
  def new(%AppSettings{} = settings) do
    %__MODULE__{
      can_manage_tokens: settings.value["can_manage_tokens"],
      can_signup: settings.value["can_signup"]
    }
  end

  def changeset(%__MODULE__{} = app_access, attrs \\ %{}) do
    {app_access, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required(Map.keys(@types))
  end
end
