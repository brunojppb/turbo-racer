defmodule TurboWeb.TeamTokenController do
  use TurboWeb, :controller
  alias Turbo.Teams
  require Logger

  def index(conn, %{"team_id" => team_id} = _params) do
    case Teams.get_team_tokens(team_id) do
      {nil, _} ->
        conn
        |> put_flash(:error, "Invalid team")
        |> redirect(to: Routes.team_path(conn, :index))

      {team, tokens} ->
        render(conn, "index.html", team: team, tokens: tokens)
    end
  end

  def create(conn, %{"token" => %{"team_id" => team_id}} = _params) do
    user = conn.assigns[:current_user]

    case Teams.generate_token(team_id, user) do
      {:ok, token} ->
        conn
        |> put_flash(:info, "Token \"#{token.token}\" generated")
        |> redirect(to: Routes.team_token_path(conn, :index, team_id))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.team_token_path(conn, :index, team_id))
    end
  end

  def delete(conn, %{"team_id" => team_id, "id" => token_id} = _params) do
    case Teams.delete_token(token_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Token successfully deleted")
        |> redirect(to: Routes.team_token_path(conn, :index, team_id))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.team_token_path(conn, :index, team_id))
    end
  end
end
