defmodule Turbo.Models.TeamToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias Turbo.Models.Team
  alias Turbo.Accounts.User

  schema "team_tokens" do
    field :token, :string
    belongs_to :team, Team
    belongs_to :user, User

    timestamps()
  end

  @type t :: %__MODULE__{
          id: integer(),
          token: String.t(),
          user_id: integer(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          team_id: integer(),
          team: Team.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  def changeset(team_token, team, user, attrs \\ %{}) do
    team_token
    |> cast(attrs, [:token])
    |> validate_required([:token])
    |> unique_constraint(:token)
    |> put_assoc(:user, user)
    |> put_assoc(:team, team)
  end
end
