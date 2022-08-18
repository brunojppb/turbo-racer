defmodule TurboWeb.ArtifactControllerTest do
  use TurboWeb.ConnCase

  alias Turbo.ArtifactsFixtures

  setup :create_and_log_in_team

  # Make sure that we have an artifact available for each test case
  # and clean-up them on_exit after each test.
  setup context do
    hash = Turbo.generate_rand_token()
    artifact = ArtifactsFixtures.artifact_fixture(hash, context.team)

    on_exit(fn ->
      ArtifactsFixtures.clean_up_artifact(hash)
    end)

    {:ok, %{artifact: artifact}}
  end

  test "PUT /v8/artifacts/:hash should return the stored artifact name", %{conn: conn, team: team} do
    hash = Turbo.generate_rand_token()

    conn =
      conn
      |> put_req_header("content-type", "application/octet-stream")
      |> put("/v8/artifacts/#{hash}?slug=#{team.name}", "some_binary_data")

    assert %{"filename" => ^hash} = json_response(conn, 201)
    ArtifactsFixtures.clean_up_artifact(hash)
  end

  test "GET /v8/artifacts/:hash should return the artifact binary", %{
    conn: conn,
    team: team,
    artifact: artifact
  } do
    conn = get(conn, "/v8/artifacts/#{artifact.hash}?slug=#{team.name}")
    assert response(conn, 200)
  end

  test "POST /v8/artifacts/events should respond with an empty JSON", %{conn: conn} do
    conn = post(conn, "/v8/artifacts/events")
    assert json_response(conn, 201) == %{}
  end
end
