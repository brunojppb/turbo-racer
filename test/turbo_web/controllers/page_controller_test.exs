defmodule TurboWeb.PageControllerTest do
  use TurboWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Open-source API for managing"
  end
end
