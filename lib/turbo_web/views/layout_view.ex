defmodule TurboWeb.LayoutView do
  use TurboWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  @doc """
  Allows rendering nested layouts on top of existing layouts,
  making them composable.
  """
  def render_layout(layout, assigns, do: content) do
    render(
      layout,
      Map.merge(assigns, %{
        inner_content: content
      })
    )
  end
end
