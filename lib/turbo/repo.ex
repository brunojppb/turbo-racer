defmodule Turbo.Repo do
  use Ecto.Repo,
    otp_app: :turbo,
    adapter: Ecto.Adapters.Postgres
end
