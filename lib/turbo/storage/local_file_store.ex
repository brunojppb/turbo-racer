defmodule Turbo.Storage.LocalFileStore do
  alias Turbo.Storage.FileStore

  @behaviour FileStore

  @impl FileStore
  def get(filename) do
    path = build_path(filename)

    if File.exists?(path) do
      {:ok, File.stream!(path)}
    else
      {:error, "#{filename} not found"}
    end
  end

  @impl FileStore
  def put(temp_file_path, filename) do
    temp_file_path
    |> File.copy(build_path(filename))
    |> case do
      {:ok, _} ->
        {:ok, filename}

      {:error, _} ->
        {:error, "Could not store file #{filename}"}
    end
  end

  defp upload_dir(), do: Application.app_dir(:turbo, "priv/uploads")
  defp build_path(filename), do: upload_dir() <> "/" <> filename
end
