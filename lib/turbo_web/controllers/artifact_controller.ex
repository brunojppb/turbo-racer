defmodule TurboWeb.ArtifactController do
  use TurboWeb, :controller
  require Logger
  alias Turbo.Storage.FileStore

  # Max size of uploaded artifacts
  @max_length 100_000_000

  def create(conn, %{"id" => id} = _params) do
    # TODO: Check if there is more chunks to read
    # and bail in case payload is larger than the limit
    {:ok, body_data, conn} = read_body(conn, length: @max_length)

    {:ok, filename} = FileStore.put_data(body_data, id)
    send_resp(conn, 200, filename)
  end

  def show(conn, %{"id" => id} = _params) do
    FileStore.get_file(id)
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

  # reduce over the stream and send chunks to the client
  defp send_chunked_stream(conn, stream) do
    Enum.reduce_while(stream, conn, fn file_chunk, conn ->
      case chunk(conn, file_chunk) do
        {:ok, conn} ->
          {:cont, conn}

        {:error, :closed} ->
          {:halt, conn}
      end
    end)
  end
end
