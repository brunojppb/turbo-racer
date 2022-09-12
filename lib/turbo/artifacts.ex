defmodule Turbo.Artifacts do
  alias Turbo.Repo
  alias Ecto.Changeset
  alias Turbo.Models.{Team, Artifact}
  alias Turbo.Storage.FileStore
  import Ecto.Query
  require Logger

  @spec create(binary(), String.t(), Team.t()) :: Turbo.result(Artifact.t())
  def create(artifact_data, hash, team) do
    with {:ok, _filename} <- FileStore.put_data(artifact_data, artifact_path(team.id, hash)),
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

      _artifact ->
        {:ok, stream} = artifact_path(team.id, hash) |> FileStore.get_file()
        {:ok, stream}
    end
  end

  @spec delete_all_from_team(team_id :: integer() | String.t()) ::
          :ok | {:error, reason :: String.t()}
  def delete_all_from_team(team_id) do
    from(a in Artifact, where: a.team_id == ^team_id)
    |> Repo.all()
    |> Enum.map(fn artifact ->
      delete(artifact.hash, artifact.team_id)
    end)
    |> Enum.reduce_while(:ok, fn delete_result, _ ->
      case delete_result do
        {:ok, _} ->
          {:cont, :ok}

        {:error, reason} ->
          Logger.error("Could not delete artifact for team_id=#{team_id} reason=#{reason}")
          {:halt, {:error, reason}}
      end
    end)
  end

  @spec delete(hash :: String.t(), team_id :: number()) :: Turbo.result(String.t())
  def delete(hash, team_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:record, fn _repo, _changes ->
      query = from a in Artifact, where: a.hash == ^hash and a.team_id == ^team_id

      case Repo.delete_all(query) do
        {1, _} ->
          {:ok, "Record deleted"}

        err ->
          {:error,
           "Error deleting artifact hash=#{hash} team_id=#{team_id}. reason=#{inspect(err)}"}
      end
    end)
    |> Ecto.Multi.run(:file, fn _repo, _changes ->
      artifact_path(team_id, hash) |> FileStore.delete_file()
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
      case delete(artifact.hash, artifact.team_id) do
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

  # Scope artifact under "team_<team_id>" directory
  # to avoid potential hash collisions for different teams.
  defp artifact_path(team_id, hash) do
    Path.join("team_#{team_id}", hash)
  end
end
