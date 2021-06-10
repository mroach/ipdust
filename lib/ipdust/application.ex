defmodule Ipdust.Application do
  @moduledoc """
  Simple app to show some client information
  """
  use Application

  def start(_type, _args) do
    children = [
      IpdustWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Ipdust.Supervisor]

    children
    |> Supervisor.start_link(opts)
    |> after_start
  end

  defp after_start({:ok, _} = result) do
    Geolix.load_database(%{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source: Application.app_dir(:ipdust, "priv/geoip/GeoLite2-City.tar.gz")
    })

    Geolix.load_database(%{
      id: :asn,
      adapter: Geolix.Adapter.MMDB2,
      source: Application.app_dir(:ipdust, "priv/geoip/GeoLite2-ASN.tar.gz")
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
