# ipdust

An app for basic ip info

## Setup on Ubuntu. Native or Windows Subsystem for Linux (WSL)

### Elixir and related deps

At the time of writing, `erlang-parsetools` and `erlang-dev` were needed for `gettext` to compile, at least on WSL

```shell
curl -fsSL  https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add -

sudo apt-add-repository "deb http://binaries.erlang-solutions.com/debian $(lsb_release -cs) contrib"

sudo apt-get update
sudo apt-get -y install esl-erlang inotify-tools elixir erlang-dev erlang-parsetools
```

### Phoenix

Probably only need to install this directly if you plan on creating new apps. Otherwise `mix deps.get` should work on its own.

```shell
mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez
```

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
