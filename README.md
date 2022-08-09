# Turbo Cache

An open-source backend for managing your [Turborepo](https://turborepo.org/) cache.

## Dependencies

To run this app locally, you will the following dependencies installed:

- Elixir
  - You can setup with asdf following this guide [here](https://thinkingelixir.com/install-elixir-using-asdf/).
- Postgres 14
  - The simplest way is to have [Docker](https://docs.docker.com/engine/install/centos/) installed and run `docker-compose up`. It will
    start up a Postgres container for your dev server.
## Starting

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Ready for Production

Deployment guides coming soon...