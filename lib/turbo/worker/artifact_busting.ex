defmodule Turbo.Worker.ArtifactBusting do
  @moduledoc """
  Oban worker that periodically cleans up stale Turborepo artifacts.

  Clean-up frequency can be configured via `ARTIFACT_BUSTING_IN_DAYS`
  environment variable.
  """

  use Oban.Worker, queue: :artifact_busting, max_attempts: 2
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"days_from_now" => days_from_now}} = _job) do
    days_from_now_in_sec = 60 * 60 * 24 * days_from_now * -1

    days_ago_date =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(days_from_now_in_sec, :second)
      |> NaiveDateTime.truncate(:second)

    Logger.info("Deleting artifacts older than #{inspect(days_ago_date)}")

    case Turbo.Artifacts.delete_older_than(days_ago_date) do
      # No artifacts to be deleted
      {[], []} ->
        Logger.info("No artifacts to delete. today=#{inspect(DateTime.utc_now())}")
        :ok

      # Old artifacts deleted successfully
      {deleted, []} ->
        Logger.info("Old artifacts deleted. hashes=#{inspect(deleted)}")
        :ok

      # Some artifacts failed to be deleted
      {_deleted, failed} ->
        Logger.error("Failed to delete old artifacts hashes=#{inspect(failed)}")
        {:error, "Some artifacts failed to be deleted. hashes=#{inspect(failed)}"}
    end
  end
end
