defmodule TurboWeb.ArtifactAuth do
  import Plug.Conn
  use TurboWeb, :controller
  alias Turbo.Teams
  require Logger

  @doc """
  Used as a plug for requiring Bearer token auth for artifact access
  """
  def require_bearer_token(conn, _opts) do
    token = get_req_header(conn, "authorization")
    handle_token(conn, token)
  end

  defp handle_token(conn, ["Bearer " <> token] = _header) do
    case Teams.get_team_by_token(token) do
      {:ok, team} ->
        assign(conn, :team, team)

      {:error, _} ->
        handle_token(conn, nil)
    end
  end

  defp handle_token(conn, _invalid_header) do
    conn
    |> send_json_resp(401, %{error: "invalid Bearer token"})
    |> halt()
  end
end
