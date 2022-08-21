defmodule Turbo.Artifacts do
  alias Turbo.Repo
  alias Ecto.Changeset
  alias Turbo.Models.{Team, Artifact}
  alias Turbo.Storage.FileStore
  import Ecto.Query
  require Logger

  @spec create(binary(), String.t(), Team.t()) :: Turbo.result(Artifact.t())
  def create(artifact_data, hash, team) do
    with {:ok, _filename} <- FileStore.put_data(artifact_data, hash),
         {:ok, artifact} <- create_artifact(hash, team) do
      {:ok, artifact}
    else
      {:error, %Changeset{} = changeset} ->
        Logger.error("Error inserting artifact: #{inspect(changeset.errors)}")
        {:error, "Could not store artifact"}

      {:error, message} ->
        Logger.error("Could not store file with hash #{hash}: #{message}")
        {:error, "could not store file"}
    end
  end

  @spec get(hash :: String.t(), team :: Team.t()) :: Turbo.result(Enumerable.t())
  def get(hash, team) do
    query = from a in Artifact, where: a.hash == ^hash and a.team_id == ^team.id

    case Repo.one(query) do
      nil ->
        {:error, "artifact not found"}

      artifact ->
        {:ok, stream} = FileStore.get_file(artifact.hash)
        {:ok, stream}
    end
  end

  @spec delete(hash :: String.t()) :: {:ok, hash :: String.t()} | {:error, reason :: String.t()}
  def delete(hash) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:record, fn _repo, _changes ->
      query = from a in Artifact, where: a.hash == ^hash

      case Repo.delete_all(query) do
        {1, _} ->
          {:ok, "Record deleted"}

        _ ->
          {:error, "Error while deleting artifact record"}
      end
    end)
    |> Ecto.Multi.run(:file, fn _repo, _changes ->
      FileStore.delete_file(hash)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _mappings} ->
        {:ok, hash}

      error ->
        {:error, error}
    end
  end

  @doc """
  Delete artifacts older than the given date.
  Error out if at least one artifact fails to be deleted, which could happen
  when dealing with the File Storage API.

  Returns a tuple with the
  - hashes of the successfully deleted artifacts
  - hashes of the artifacts that failed to be deleted
  """
  @spec delete_older_than(date :: NaiveDateTime.t()) ::
          {deleted :: list(String.t()), failed :: list(String.t())}
  def delete_older_than(%NaiveDateTime{} = date) do
    # Delete artifacts one by one so we make sure
    # that for failed artifacts we can retry them later and
    # do not halt the entire process because of one error.
    # Possible TODO: Delete artifacts in batches
    from(a in Artifact, where: a.inserted_at <= ^date)
    |> Repo.all()
    |> Enum.reduce({[], []}, fn artifact, {deleted, failed} ->
      # Collect list of hashes deleted + failed
      case delete(artifact.hash) do
        {:ok, hash} ->
          {[hash | deleted], failed}

        {:error, _err} ->
          {deleted, [artifact.hash | failed]}
      end
    end)
  end

  defp create_artifact(hash, team) do
    %Artifact{}
    |> Artifact.changeset(team, %{hash: hash})
    |> Repo.insert()
  end
end
