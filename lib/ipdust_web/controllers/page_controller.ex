defmodule IpdustWeb.PageController do
  use IpdustWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def net(conn, _params) do
    conn =
      case RDAP.lookup_ip(conn.remote_ip) do
        {:ok, response} ->
          conn
          |> assign(:raw_response, Jason.encode!(response.raw_response, pretty: true))
          |> assign(:network_id, Ipdust.RDAPNetworkId.identify(response))

        _ ->
          conn
          |> assign(:raw_response, nil)
          |> assign(:network_id, "No network information")
      end

    render(conn, "net.html")
  end

  def json(conn, _params) do
    render(conn, "json.json")
  end

  def ip(conn, _params) do
    render(conn, "ip.txt")
  end
end
