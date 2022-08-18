defmodule Turbo.Models.Artifact do
  use Ecto.Schema
  import Ecto.Changeset
  alias Turbo.Models.Team

  schema "artifacts" do
    field :hash, :string
    belongs_to :team, Team

    timestamps()
  end

  @type t :: %__MODULE__{
          id: integer(),
          hash: String.t(),
          team_id: integer(),
          team: Team.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  def changeset(artifact, team, attrs \\ %{}) do
    artifact
    |> cast(attrs, [:hash])
    |> validate_required([:hash])
    |> unique_constraint(:hash)
    |> put_assoc(:team, team)
  end
end
