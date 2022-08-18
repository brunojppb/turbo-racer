defmodule Turbo.Models.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias Turbo.Accounts.User
  alias Turbo.Models.TeamToken

  schema "teams" do
    field :name, :string
    belongs_to :user, User
    has_many :tokens, TeamToken

    timestamps()
  end

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          user_id: integer(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          tokens: list(TeamToken.t()) | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  def changeset(team, user, attrs \\ %{}) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> put_assoc(:user, user)
  end
end
