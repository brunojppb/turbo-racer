# Turborepo Cache

An open-source backend for managing your [Turborepo](https://turborepo.org/) cache.

> **Note**
> This is not ready for production yet. It can already be used for storing
> artifacts in the filesystem, but is missing the S3 integration.
> I will create a tag and prepare a Github Release once it is ready.

## Features

- [x] Store artifacts
  - [x] Using file system
  - [ ] Using S3
- [x] Web UI for managing
  - [x] Teams
  - [x] Tokens
  - [ ] Manage artifact purging background job
- [x] Provide artifacts scoped by teams

## Dependencies

To run this app locally, you will the following dependencies installed:

- [Elixir](https://elixir-lang.org/)
  - You can quickly setup with [asdf](https://asdf-vm.com/) following this guide [here](https://thinkingelixir.com/install-elixir-using-asdf/).
- Postgres 14
  - The simplest way is to have [Docker](https://docs.docker.com/engine/install/centos/) installed and run `docker-compose up`. It will
    start up a Postgres container for your dev server.
## Starting development

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running tests

Make sure that the Postgres container is running and execute `mix test`

## Ready for Production

Deployment guides with Docker coming soon...