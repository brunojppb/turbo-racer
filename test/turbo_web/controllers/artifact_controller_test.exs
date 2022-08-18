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

  describe "PUT /v8/artifacts/:hash" do
    test "should return the stored artifact name", %{conn: conn, team: team} do
      hash = Turbo.generate_rand_token()

      conn =
        conn
        |> put_req_header("content-type", "application/octet-stream")
        |> put("/v8/artifacts/#{hash}?slug=#{team.name}", "some_binary_data")

      assert %{"filename" => ^hash} = json_response(conn, 201)
      ArtifactsFixtures.clean_up_artifact(hash)
    end

    test "return unauthorized if Bearer token isn't present" do
      conn =
        build_conn()
        |> put_req_header("content-type", "application/octet-stream")
        |> put("/v8/artifacts/random-hash?slug=team", "some_binary_data")

      assert response(conn, 401)
    end
  end

  describe "GET /v8/artifacts/:hash" do
    test "should return the artifact binary", %{
      conn: conn,
      team: team,
      artifact: artifact
    } do
      conn = get(conn, "/v8/artifacts/#{artifact.hash}?slug=#{team.name}")
      assert response(conn, 200)
    end

    test "should return not found in case of wrong hash", %{
      conn: conn,
      team: team
    } do
      conn = get(conn, "/v8/artifacts/wrong-hash?slug=#{team.name}")
      assert response(conn, 404)
    end

    test "should return not found in case of team and token mismatch", %{
      conn: conn,
      artifact: artifact
    } do
      conn = get(conn, "/v8/artifacts/#{artifact.hash}?slug=other-team")
      assert response(conn, 404)
    end

    test "return unauthorized if Bearer token isn't present" do
      conn =
        build_conn()
        |> get("/v8/artifacts/random-hash?slug=team")

      assert response(conn, 401)
    end
  end

  describe "POST /v8/artifacts/events" do
    test "should respond with an empty JSON", %{conn: conn} do
      conn = post(conn, "/v8/artifacts/events")
      assert json_response(conn, 201) == %{}
    end
  end
end
