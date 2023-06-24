# Turbo Racer

![Workflow badge](https://github.com/brunojppb/turbo-racer/actions/workflows/checks.yml/badge.svg?branch=main)

An open-source backend with a Web UI for managing your
[Turborepo](https://turbo.build/repo) cache.

## Features

There are a few open-source turborepo cache backends out there, but all of them
seem to lack management around tokens and teams. If you work in an enterprise,
access management is crucial for keeping permissions segregated and I could not
find anything supporting that.

So I've built my own remote cache. Besides giving you full control
over creating teams, issuing tokens for specific teams and who has access to a
given token, it also allows you to go from a simple deployment using your file
system as artifact storage to going full scale using a S3-compatible backend
service.

Here is what is available for you:

- [x] Store artifacts
  - [x] Using file system
  - [x] Using S3 (Tested with the following)
    - [x] [Cloudflare R2](https://developers.cloudflare.com/r2/platform/s3-compatibility/api/)
    - [x] [AWS S3](https://aws.amazon.com/s3/)
- [x] Cache busting
  - [x] Automatic artifact busting to keep your disk or your S3 bill sane.
    - [x] Configurable busting period via environment variable (see
          `docker-compose.prod.yml`)
- [x] Management via a Web UI for
  - [x] Teams
  - [x] Tokens
  - [x] User sign-up/sign-in (Will refine this part with more permission
        controls)
- [x] Whether users can create accounts (Admin settings)

## What is coming next

- [ ] Statistics dashboard

## Deploying to Production

Turbo Racer is designed to be deployed with Docker. The simplest way is to use
[docker-compose](https://docs.docker.com/compose/). Have a look at the
`docker-compose.prod.yml` in the root directory for an deployment example.

### Docker images

Whenever a new release is out, a new Docker image is built and pushed to Docker
hub.  
Here you can find the latest tags:
[brunojppb/turbo-racer](https://hub.docker.com/r/brunojppb/turbo-racer/tags)

### Admin account when running for the first time

Once you deploy Turbo Racer for the first time, you must create an admin
account. The first account you signup with from the `Sign up` Web UI will be the
system admin.

Admins can control whether users can create accounts so they can login and
manage teams and tokens.

### Deploy to Digital Ocean

You can use our Digital Ocean template to get this running quickly in a droplet.

[![Deploy to Digital Ocean](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/brunojppb/turbo-racer/tree/main&refcode=3a18edba5ee4)

## Dev Dependencies

To run this app locally, you need the following dependencies installed:

- [Elixir 1.14](https://elixir-lang.org/) and
  [Erlang OTP 25](https://www.erlang.org/)
  - You can quickly do it with [asdf](https://asdf-vm.com/). Once asdf is
    installed and then execute `asdf install` within the context of the
    `turbo-racer` directory. It will automatically pick up the right Elixir and
    Erlang versions defined in the `.tool-versions` file at the root of the repo.
- [Postgres 14](https://www.postgresql.org/)
  - The simplest way is to have
    [Docker](https://docs.docker.com/engine/install/centos/) installed and run
    `docker-compose up`. It will start up a Postgres container with a database
    ready for your dev server and for running tests.

### Starting development

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with
  `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Running tests

Make sure that the Postgres container is running and execute `mix test`
