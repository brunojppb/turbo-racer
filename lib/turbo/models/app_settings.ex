defmodule Turbo.Models.AppSettings do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  AppSettings represent general, global configuration options given
  given to admins of the system. It's shape is a generic JSONB column
  that should be transformed and handled by specific settings structs.
  See `Turbo.Settings.AppAccess` as a reference on how to use it.
  """

  schema "app_settings" do
    field :key, :string
    field :value, :map

    timestamps()
  end

  @type t :: %__MODULE__{
          id: integer(),
          key: String.t(),
          value: map(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  def changeset(%__MODULE__{} = app_settings, attrs \\ %{}) do
    app_settings
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
    |> unique_constraint(:key)
  end
end
