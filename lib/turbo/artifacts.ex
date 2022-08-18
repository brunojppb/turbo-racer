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

  @spec get(hash :: String.t(), team :: Team.t()) :: Turbo.result({Artifact.t(), Enumerable.t()})
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

  defp create_artifact(hash, team) do
    %Artifact{}
    |> Artifact.changeset(team, %{hash: hash})
    |> Repo.insert()
  end
end
