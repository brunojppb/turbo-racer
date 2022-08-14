defmodule TurboWeb.TeamController do
  use TurboWeb, :controller

  # TODO: These endpoints seem to be used by Vercel only
  # But we can probably hook up an UI here later on.
  def user(conn, _params) do
    send_resp(conn, 200, Jason.encode!(%{}))
  end

  def teams(conn, _params) do
    send_resp(conn, 200, Jason.encode!(%{}))
  end
end
