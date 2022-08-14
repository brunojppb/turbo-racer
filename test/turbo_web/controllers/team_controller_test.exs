defmodule TurboWeb.TeamControllerTest do
  use TurboWeb.ConnCase

  test "GET /v2/teams should respond with an empty JSON", %{conn: conn} do
    conn = get(conn, "/v2/teams")
    assert json_response(conn, 200) == %{}
  end

  test "GET /v2/user should respond with an empty JSON", %{conn: conn} do
    conn = get(conn, "/v2/user")
    assert json_response(conn, 200) == %{}
  end
end
