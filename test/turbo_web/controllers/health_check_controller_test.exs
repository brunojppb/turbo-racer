defmodule TurboWeb.HealthCheckControllerTest do
  use TurboWeb.ConnCase

  describe("GET /management/health") do
    test "Should report healthy when database is available", %{conn: conn} do
      conn = get(conn, "/management/health")
      assert %{"status" => "ok"} = json_response(conn, 200)
    end
  end
end
