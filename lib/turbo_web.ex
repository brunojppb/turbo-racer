defmodule TurboWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use TurboWeb, :controller
      use TurboWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: TurboWeb

      import Plug.Conn
      import TurboWeb.Gettext
      alias TurboWeb.Router.Helpers, as: Routes

      @doc """
      Render response in JSON format with the appropriate headers
      """
      @spec send_json_resp(Plug.Conn.t(), integer(), map()) :: Plug.Conn.t() | none()
      def send_json_resp(conn, http_status, params) do
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(http_status, Jason.encode!(params))
      end

      @doc """
      Send stream to the client by reducing over the stream
      """
      @spec send_chunked_stream(Plug.Conn.t(), Enumerable.t()) :: Plug.Conn.t() | none()
      def send_chunked_stream(conn, stream) do
        Enum.reduce_while(stream, conn, fn file_chunk, conn ->
          case chunk(conn, file_chunk) do
            {:ok, conn} ->
              {:cont, conn}

            {:error, :closed} ->
              {:halt, conn}
          end
        end)
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/turbo_web/templates",
        namespace: TurboWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {TurboWeb.LayoutView, "live.html"}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import TurboWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import TurboWeb.ErrorHelpers
      import TurboWeb.Gettext
      alias TurboWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
