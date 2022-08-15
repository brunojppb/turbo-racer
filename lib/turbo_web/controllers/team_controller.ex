defmodule TurboWeb.TeamController do
  use TurboWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # TODO: These endpoints seem to be used by Vercel only
  # But we can probably hook up an UI here later on.
  def user(conn, _params) do
    send_json_resp(conn, 200, %{})
  end

  def teams(conn, _params) do
    send_json_resp(conn, 200, %{})
  end
end
