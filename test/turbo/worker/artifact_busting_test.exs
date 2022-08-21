defmodule Turbo.Worker.ArtifactBustingTest do
  use Turbo.DataCase
  use Oban.Testing, repo: Turbo.Repo

  alias Turbo.Models.Artifact

  setup do
    ten_days_ago = 10
    minus_ten_days_in_sec = 60 * 60 * 24 * ten_days_ago * -1

    ten_days_ago_date =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(minus_ten_days_in_sec, :second)
      |> NaiveDateTime.truncate(:second)

    old_artifact = Turbo.ArtifactsFixtures.stale_artifact_fixture("old-hash", ten_days_ago_date)
    new_artifact = Turbo.ArtifactsFixtures.new_artifact_fixture("new-hash")

    # Just make sure that even if the test fails, the artifact will be cleaned-up.
    # In case it has been deleted successfully during the tests, we can safely ignore.
    on_exit(fn ->
      Turbo.ArtifactsFixtures.maybe_clean_up_artifact(old_artifact.hash)
      Turbo.ArtifactsFixtures.maybe_clean_up_artifact(new_artifact.hash)
    end)

    %{
      old_artifact: old_artifact,
      new_artifact: new_artifact,
      days_from_now: ten_days_ago
    }
  end

  describe "Turbo.Worker.ArtifactBusting should" do
    test "delete artifacts older than the given days", %{
      old_artifact: old_artifact,
      days_from_now: days_from_now
    } do
      :ok = perform_job(Turbo.Worker.ArtifactBusting, %{days_from_now: days_from_now})
      assert nil == Turbo.Repo.get(Artifact, old_artifact.id)
    end

    test "keep artifacts newer than the given days", %{
      new_artifact: %Artifact{id: id} = new_artifact,
      days_from_now: days_from_now
    } do
      :ok = perform_job(Turbo.Worker.ArtifactBusting, %{days_from_now: days_from_now})

      assert %Artifact{id: ^id} = Turbo.Repo.get(Artifact, new_artifact.id)
    end
  end
end
