defmodule Turbo.Storage.LocalFileStoreTest do
  use ExUnit.Case, async: true
  alias Turbo.Storage.FileStore

  defp get_temp_file(filename) do
    dir = System.tmp_dir!()
    tmp_file_path = Path.join(dir, filename)
    :ok = File.write!(tmp_file_path, "binary_content")
    tmp_file_path
  end

  describe "LocalFileStore should" do
    test "store file in the local filesystem" do
      hash = "0da9e30c6776aa43"
      tmp_file_path = get_temp_file(hash)

      {:ok, ^hash} = FileStore.put_file(tmp_file_path, hash)
      {:ok, ^hash} = FileStore.delete_file(hash)
    end

    test "store binary content into a file" do
      hash = "0da9e30c6776aa44"
      binary_content = "i_am_some_binary_content"
      {:ok, ^hash} = FileStore.put_data(binary_content, hash)
      {:ok, ^hash} = FileStore.delete_file(hash)
    end

    test "get binary file as a stream" do
      hash = "0da9e30c6776aa445"
      binary_content = "i_am_some_binary_content"
      {:ok, ^hash} = FileStore.put_data(binary_content, hash)
      {:ok, stream} = FileStore.get_file(hash)
      content = Enum.join(stream, "")
      assert content == "i_am_some_binary_content"
      {:ok, ^hash} = FileStore.delete_file(hash)
    end
  end
end
