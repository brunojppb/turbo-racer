defmodule Turbo.Storage.S3Store do
  @behaviour Turbo.Storage.FileStore

  alias ExAws.S3
  require Logger

  def get_file(filename) do
    file_path = remote_file_path(filename)

    try do
      stream =
        get_bucket_name()
        |> S3.download_file(file_path, :memory)
        |> ExAws.stream!()

      {:ok, stream}
    rescue
      err ->
        Logger.error("Could not fetch S3 file reason=#{inspect(err)}}")
        {:error, "could not get file #{file_path}"}
    end
  end

  def put_file(temp_file_path, filename), do: upload_file(temp_file_path, filename)
  def put_data(data, filename), do: upload_data(data, filename)

  def delete_file(filename) when is_binary(filename) do
    get_bucket_name()
    |> S3.delete_object(remote_file_path(filename))
    |> ExAws.request()
    |> case do
      {:ok, _response} ->
        Logger.info("File #{filename} deleted from S3.")
        {:ok, filename}

      {:error, err} ->
        Logger.error("could not delete file #{remote_file_path(filename)} error=#{inspect(err)}")
        {:error, err}
    end
  end

  defp upload_data(binary_data, filename) do
    tmp_file = build_tmp_file_path(filename)
    :ok = File.write(tmp_file, binary_data)

    result = upload_file(tmp_file, filename)
    :ok = File.rm(tmp_file)
    result
  end

  defp upload_file(file_path, filename) do
    file_path
    |> S3.Upload.stream_file()
    |> S3.upload(get_bucket_name(), remote_file_path(filename))
    |> ExAws.request()
    |> case do
      {:ok, _response} ->
        Logger.info("File #{filename} uploaded successfully.")
        {:ok, filename}

      {:error, err} ->
        Logger.error("Could not upload file #{filename}. error=#{inspect(err)}")
        {:error, err}
    end
  end

  # Make sure the temp dir path accounts for
  # path components in the filename
  defp build_tmp_file_path(filename) do
    System.tmp_dir!()
    |> Path.join(filename)
    |> Path.dirname()
    |> File.mkdir_p!()
    |> case do
      _ ->
        Path.join(System.tmp_dir!(), filename)
    end
  end

  # Filenames can include the artifact path,
  # usually scoped under the team ID folder.
  defp remote_file_path(filename) do
    Path.join("artifacts", filename)
  end

  defp get_bucket_name() do
    Application.fetch_env!(:turbo, :s3_bucket_name)
  end
end
