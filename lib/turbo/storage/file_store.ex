defmodule Turbo.Storage.FileStore do
  @moduledoc """
  Behavior for managing file uploads and reads to S3.
  """
  @type t :: module()

  @doc """
  Put the given file to a data storage, S3 compatible
  Returns the filename in case of success.
  """
  @callback put(temp_file_path :: String.t(), filename :: String.t()) :: Turbo.result(String.t())

  @doc """
  Get the given file and return a stream that can
  be passed down to the client.
  """
  @callback get(filename :: String.t()) :: Turbo.result(Enumerable.t())

  @spec put(temp_file_path :: String.t(), filename :: String.t()) :: Turbo.result(String.t())
  def put(temp_file_path, filename), do: impl().put(temp_file_path, filename)

  @spec get(filename :: String.t()) :: Turbo.result(Stream)
  def get(filename), do: impl().get(filename)

  @spec impl() :: __MODULE__.t()
  defp impl() do
    Application.get_env(:turbo, :file_store, Turbo.Storage.LocalStore)
  end
end
