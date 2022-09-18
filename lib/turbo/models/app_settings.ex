defmodule Turbo.Models.AppSettings do
  use Ecto.Schema
  import Ecto.Changeset

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

  def changeset(app_settings, attrs \\ %{}) do
    app_settings
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
    |> unique_constraint(:key)
  end
end
