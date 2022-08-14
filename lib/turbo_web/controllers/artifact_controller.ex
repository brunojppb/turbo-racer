defmodule TurboWeb.ArtifactController do
  @moduledoc """
  Reference API implementation for the the artifacts contract defined in the original
  [Turborepo client](https://github.com/vercel/turborepo/blob/main/cli/internal/client/client.go)

  This module should expose two endpoints:
  - GET /v8/artifacts/:hash
  - PUT /v8/artifacts/:hash
  """
  use TurboWeb, :controller
  alias Turbo.Storage.FileStore
  require Logger

  # Max size of uploaded artifacts
  @max_length 100_000_000

  def create(conn, %{"hash" => hash} = _params) do
    # TODO: Check if there is more chunks to read
    # and bail in case payload is larger than the limit
    {:ok, body_data, conn} = read_body(conn, length: @max_length)

    {:ok, filename} = FileStore.put_data(body_data, hash)

    # TODO: Add x-artifact-duration that should be stored in the DB
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(201, Jason.encode!(%{filename: filename}))
  end

  # TODO: Looks like this is an analytics endpoint used by Vercel
  # to collect metrics. We could probably aggregate on it later on
  def events(conn, _params) do
    send_json_resp(conn, 201, %{})
  end

  def show(conn, %{"hash" => hash} = _params) do
    FileStore.get_file(hash)
    |> stream_resp(conn)
  end

  defp stream_resp({:error, _}, conn) do
    send_resp(conn, 404, "Error 404: Artifact not found")
  end

  defp stream_resp({:ok, stream}, conn) do
    conn
    |> send_chunked(200)
    |> send_chunked_stream(stream)
  end
end
