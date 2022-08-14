defmodule TurboWeb.ArtifactControllerTest do
  use TurboWeb.ConnCase
  alias Turbo.Storage.FileStore

  test "PUT /v8/artifacts/:hash should return the stored artifact name", %{conn: conn} do
    hash = "0da9e30c6776bb43"

    conn =
      conn
      |> put_req_header("content-type", "application/octet-stream")
      |> put("/v8/artifacts/#{hash}", "binary_data")

    assert %{"filename" => ^hash} = json_response(conn, 201)
    {:ok, _} = FileStore.delete_file(hash)
  end

  test "GET /v8/artifacts/:hash should return the artifact binary", %{conn: conn} do
    hash = "0da9e30c6776bb43"
    {:ok, _filename} = FileStore.put_data("i_am_some_binary", hash)

    conn = get(conn, "/v8/artifacts/#{hash}")

    assert response(conn, 200) =~ "i_am_some_binary"
    {:ok, _} = FileStore.delete_file(hash)
  end

  test "POST /v8/artifacts/events should respond with an empty JSON", %{conn: conn} do
    conn = post(conn, "/v8/artifacts/events")
    assert json_response(conn, 201) == %{}
  end
end
