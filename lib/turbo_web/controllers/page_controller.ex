defmodule TurboWeb.PageController do
  use TurboWeb, :controller

  def index(conn, _params) do
    case conn.assigns[:current_user] do
      nil -> render(conn, "index.html")
      _ -> redirect(conn, to: ~p"/teams")
    end
  end
end
