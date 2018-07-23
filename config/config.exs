# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ipdust,
  ecto_repos: [Ipdust.Repo]

# Configures the endpoint
config :ipdust, IpdustWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yZbCGGex99o7DAcju6oQkeFD3xQC073m4ZY8wLkjLuiIlVCf6DwQQSgvdR8azcKL",
  render_errors: [view: IpdustWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ipdust.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"