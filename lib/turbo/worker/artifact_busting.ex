defmodule Turbo.Worker.ArtifactBusting do
  @moduledoc """
  Oban worker that periodically cleans up stale Turborepo artifacts.

  Clean-up frequency can be configured via `ARTIFACT_BUSTING_IN_DAYS`
  environment variable.
  """

  use Oban.Worker, queue: :artifact_busting, max_attempts: 2
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{} = _job) do
    Logger.info("Artifact busting executing...")
    :ok
  end
end
