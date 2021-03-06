defmodule IpdustWeb.Plugs.IpInfo do
  @moduledoc """
  Adds information about the client to the connection
  * Remote IP
  * Hostname
  * HTTPS
  * Server time
  * Headers
  * GeoIP info
  """
  import Plug.Conn
  require Logger

  @mute_headers ~w[
    x-cluster-client-ip
    x-real-ip
    x-forwarded-proto
  ]

  def init(default), do: default

  def call(conn, _default) do
    remote_ip = conn.remote_ip

    conn
    |> assign(:remote_ip, ip_to_string(remote_ip))
    |> assign(:hostname, hostname(remote_ip))
    |> assign(:is_https, is_https(conn))
    |> assign(:is_proxied, is_proxied(conn))
    |> assign(:server_time, DateTime.utc_now())
    |> assign_headers()
    |> assign_geoip_fields(remote_ip)
  end

  def assign_geoip_fields(conn, ip) when is_tuple(ip),
    do: assign_geoip_fields(conn, ip_to_string(ip))

  def assign_geoip_fields(conn, ip) when is_binary(ip),
    do: query_and_assign_geoip_fields(conn, ip)

  def query_and_assign_geoip_fields(conn, ip) do
    result = Geolix.lookup(ip)

    conn
    |> maybe_assign_geoip_location(result)
    |> maybe_assign_geoip_asn(result)
  end

  def maybe_assign_geoip_location(conn, %{city: result}) when result != nil do
    Logger.info("GeoIP success: #{result.country.iso_code}")

    conn
    |> assign(:geoip_success, true)
    |> assign_geoip_city(result.city)
    |> assign_geoip_country(result.country)
  end

  def maybe_assign_geoip_location(conn, _),
    do: assign(conn, :geoip_success, false)

  def maybe_assign_geoip_asn(conn, %{asn: result}) when result != nil do
    Logger.info("GeoIP ASN success: #{result.autonomous_system_organization}")

    conn
    |> assign(:geoip_asn_success, true)
    |> assign_geoip_asn_name(result)
  end

  def maybe_assign_geoip_asn(conn, _),
    do: assign(conn, :geoip_asn_success, false)

  def assign_geoip_city(conn, %{name: city}) do
    conn
    |> assign(:geoip_city, city)
  end

  def assign_geoip_city(conn, nil), do: conn

  def assign_geoip_country(conn, %{name: country, iso_code: code}) do
    conn
    |> assign(:geoip_country, country)
    |> assign(:geoip_country_iso, code)
  end

  def assign_geoip_country(conn, nil), do: conn

  def assign_geoip_asn_name(conn, %{autonomous_system_organization: name}),
    do: assign(conn, :geoip_asn_name, name)

  def assign_geoip_asn_name(conn, _), do: conn

  def assign_headers(conn) do
    conn |> assign(:headers, filtered_headers(conn))
  end

  @doc """
    Indicate if the current connection is over HTTPS based on the scheme connected to
    the Phoenix server or based on the X-Forwarded-Proto header from the load balancer

  ## Examples
      iex> %Plug.Conn{scheme: :https} |> IpdustWeb.Plugs.IpInfo.is_https
      true

      iex> %Plug.Conn{scheme: :http}
      ...> |> Plug.Conn.put_req_header("x-forwarded-proto", "https")
      ...> |> IpdustWeb.Plugs.IpInfo.is_https
      true
  """
  def is_https(%Plug.Conn{scheme: :https}), do: true

  def is_https(%Plug.Conn{} = conn) do
    case get_req_header(conn, "x-forwarded-proto") do
      ["https"] -> true
      _ -> false
    end
  end

  @doc """
  Determine if the request is being proxied by checking for presence of the `via` header

  ## Example:
    iex> conn = Plug.Conn.put_req_header(%Plug.Conn{}, "via", "proxy.junk.net")
    ...> IpdustWeb.Plugs.IpInfo.is_proxied(conn)
    true
  """
  def is_proxied(%Plug.Conn{} = conn) do
    case get_req_header(conn, "via") do
      [] -> false
      _ -> true
    end
  end

  @doc """
    The IP address in the connection comes back as a four-part tuple
    Convert it to a string

  ## Examples

      iex> IpdustWeb.Plugs.IpInfo.ip_to_string({10, 65, 49, 10})
      "10.65.49.10"
  """
  def ip_to_string(ip) when is_tuple(ip) do
    ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  @doc """
    Convert an IP address from a string into a Tuple which most :inet methods expect

  ## Examples

    iex> IpdustWeb.Plugs.IpInfo.ip_from_string("24.34.153.229")
    {24,34,153,229}
  """
  def ip_from_string(ip) do
    case :inet.parse_address(to_charlist(ip)) do
      {:ok, ip_tuple} -> ip_tuple
      _ -> nil
    end
  end

  @doc """
    Gets the hostname based on the given ip address

  ## Examples

      iex> IpdustWeb.Plugs.IpInfo.hostname({127, 0, 0, 1})
      "localhost"

      IpdustWeb.Plugs.IpInfo.hostname({8, 8, 8, 8})
      "dns.google"
  """
  def hostname(ip) when is_tuple(ip) do
    case :inet.gethostbyaddr(ip) do
      {:ok, {:hostent, hostname, _, _, _, _}} -> to_string(hostname)
      _ -> nil
    end
  end

  @doc """
    Filter muted headers

  ## Examples
      iex> %Plug.Conn{}
      ...> |> Plug.Conn.put_req_header("x-forwarded-proto", "https")
      ...> |> Plug.Conn.put_req_header("user-agent", "Netscape")
      ...> |> IpdustWeb.Plugs.IpInfo.filtered_headers
      [{"user-agent", "Netscape"}]
  """
  def filtered_headers(conn) do
    conn.req_headers
    |> Enum.reject(fn {key, _} -> Enum.member?(@mute_headers, key) end)
  end
end
