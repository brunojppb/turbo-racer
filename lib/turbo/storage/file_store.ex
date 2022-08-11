defmodule Turbo.Storage.FileStore do
  @moduledoc """
  Behavior for managing file uploads and reads to S3.
  """
  @type t :: module()

  @doc """
  Copy the given file to a data storage.
  Returns the filename in case of success.
  """
  @callback put_file(temp_file_path :: String.t(), filename :: String.t()) ::
              Turbo.result(String.t())

  @doc """
  Store the given binary data to a data storage.
  Returns the filename in case of success.
  """
  @callback put_data(data :: binary(), filename :: String.t()) :: Turbo.result(String.t())

  @doc """
  Get the given file and return a stream that can
  be passed down to the client.
  """
  @callback get_file(filename :: String.t()) :: Turbo.result(Enumerable.t())

  @spec put_file(temp_file_path :: String.t(), filename :: String.t()) :: Turbo.result(String.t())
  def put_file(temp_file_path, filename), do: impl().put_file(temp_file_path, filename)

  @spec put_data(data :: binary(), filename :: String.t()) :: Turbo.result(String.t())
  def put_data(data, filename), do: impl().put_data(data, filename)

  @spec get_file(filename :: String.t()) :: Turbo.result(Stream)
  def get_file(filename), do: impl().get_file(filename)

  @spec impl() :: __MODULE__.t()
  defp impl() do
    Application.get_env(:turbo, :file_store, Turbo.Storage.LocalFileStore)
  end
end
