import Config

config :ipdust, IpdustWeb.Endpoint,
  url: [host: System.get_env("HOSTNAME"), port: 80]
