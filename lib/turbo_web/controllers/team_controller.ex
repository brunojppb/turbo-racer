defmodule TurboWeb.TeamController do
  use TurboWeb, :controller
  alias Turbo.Teams

  def index(conn, _params) do
    teams = Teams.get_all()
    render(conn, "index.html", teams: teams)
  end

  def new(conn, _params) do
    user = conn.assigns[:current_user]
    changeset = Teams.change(user)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"team" => params}) do
    user = conn.assigns[:current_user]

    case Teams.create(user, params) do
      {:ok, _team} ->
        redirect(conn, to: ~p"/teams")

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => team_id} = _params) do
    {flash_level, message} =
      case Teams.delete(team_id) do
        {:ok, _} ->
          {:info, "Team #{team_id} and all its associated artifacts and tokens deleted."}

        {:error, _} ->
          {:error, "Could not delete team with ID #{team_id}"}
      end

    conn
    |> put_flash(flash_level, message)
    |> redirect(to: ~p"/teams")
  end

  # TODO: These endpoints seem to be used by Vercel only
  # But we can probably hook up an UI here later on.
  def user(conn, _params) do
    send_json_resp(conn, 200, %{})
  end

  def teams(conn, _params) do
    send_json_resp(conn, 200, %{})
  end
end
