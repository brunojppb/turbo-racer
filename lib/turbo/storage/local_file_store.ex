defmodule Turbo.Storage.LocalFileStore do
  alias Turbo.Storage.FileStore

  @behaviour FileStore

  @impl FileStore
  def get_file(filename) do
    path = build_path(filename)

    if File.exists?(path) do
      {:ok, File.stream!(path, 2048)}
    else
      {:error, "#{filename} not found"}
    end
  end

  @impl FileStore
  def delete_file(filename) when is_binary(filename) do
    path = build_path(filename)

    if File.exists?(path) do
      case File.rm(path) do
        :ok ->
          {:ok, filename}

        {:error, _reason} ->
          {:error, "Could not delete file #{filename}"}
      end
    else
      {:error, "File #{filename} not found"}
    end
  end

  @impl FileStore
  def put_data(data, filename) do
    file_path = build_path(filename)
    :ok = File.write(file_path, data)

    {:ok, filename}
  end

  @impl FileStore
  def put_file(temp_file_path, filename) do
    temp_file_path
    |> File.copy(build_path(filename))
    |> case do
      {:ok, _} ->
        {:ok, filename}

      {:error, _} ->
        {:error, "Could not store file #{filename}"}
    end
  end

  defp upload_dir() do
    # During development and tests, we use the current priv folder for storing artifacts.
    if Application.fetch_env!(:turbo, :use_priv_for_artifacts) do
      Application.app_dir(:turbo, Path.join("priv", "turbo_artifacts"))
    else
      # In production using Docker, we have a stable path
      # that doesn't depend on the compiled release path
      "/var/turbo_artifacts"
    end
  end

  # Make sure that the upload folder exists first
  defp build_path(filename) do
    if not File.exists?(upload_dir()) do
      File.mkdir(upload_dir())
    end

    Path.join(upload_dir(), filename)
    |> Path.dirname()
    |> case do
      "." ->
        Path.join(upload_dir(), filename)

      path ->
        if not File.exists?(path) do
          File.mkdir_p(path)
        end

        Path.join(upload_dir(), filename)
    end
  end
end
