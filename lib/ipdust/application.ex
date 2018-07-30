defmodule Ipdust.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Ipdust.Repo, []),
      # Start the endpoint when the application starts
      supervisor(IpdustWeb.Endpoint, []),
      # Start your own worker by calling: Ipdust.Worker.start_link(arg1, arg2, arg3)
      # worker(Ipdust.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ipdust.Supervisor]

    Supervisor.start_link(children, opts)
    |> after_start
  end

  defp after_start({:ok, _} = result) do
    Geolix.load_database(%{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source: Application.app_dir(:ipdust, "priv/geoip/GeoLite2-City.tar.gz")
    })
    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    IpdustWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
