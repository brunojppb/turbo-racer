defmodule Turbo.Settings.SettingsContextTest do
  use Turbo.DataCase, async: true

  alias Turbo.Settings.{AppAccess, SettingsContext}

  describe "get_app_access/0" do
    test "always returns an existing app settings" do
      assert %AppAccess{} = SettingsContext.get_app_access()
    end
  end

  describe "update_app_access/1" do
    test "Updates existing app access" do
      assert {:ok, %AppAccess{can_manage_tokens: false, can_signup: true}} =
               SettingsContext.update_app_access(%{
                 "can_manage_tokens" => "false",
                 "can_signup" => "true"
               })
    end

    test "validates app access fields" do
      {:error, changeset} =
        SettingsContext.update_app_access(%{
          "can_manage_tokens" => "invalid",
          "can_signup" => "invalid"
        })

      assert %{
               can_manage_tokens: ["is invalid"],
               can_signup: ["is invalid"]
             } = errors_on(changeset)
    end
  end
end
