defmodule Turbo.ArtifactsFixtures do
  @moduledoc """
  Test helpers for creating entities via the
  `Turbo.Artifacts` context.
  """

  alias Turbo.Artifacts

  def artifact_fixture(hash, team) do
    {:ok, artifact} = Artifacts.create("some_binary_encoded_data", hash, team)
    artifact
  end

  def clean_up_artifact(hash) do
    true = Artifacts.delete(hash)
  end
end
