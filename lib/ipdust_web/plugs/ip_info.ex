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

  def init(default), do: default

  def call(conn, _default) do
    remote_ip = conn.remote_ip
    conn
    |> assign(:remote_ip, ip_to_string(remote_ip))
    |> assign(:hostname, hostname(remote_ip))
    |> assign(:is_https, is_https(conn))
    |> assign(:server_time, DateTime.utc_now)
    |> assign(:headers, conn.req_headers)
    |> assign_geoip_fields(remote_ip)
  end

  def assign_geoip_fields(conn, ip) when is_tuple(ip), do: assign_geoip_fields(conn, ip_to_string(ip))
  def assign_geoip_fields(conn, ip) do
    case Geolix.lookup(ip, where: :city) do
      nil ->
        Logger.info "GeoIP failed for #{ip}"
        assign(conn, :geoip_success, false)
      result ->
        Logger.info "GeoIP success for #{ip} #{result.country.iso_code}"
        conn
        |> assign(:geoip_success, true)
        |> assign_geoip_city(result.city)
        |> assign_geoip_country(result.country)
    end
  end

  def assign_geoip_city(conn, %Geolix.Record.City{name: city} = _) do
    conn
    |> assign(:geoip_city, city)
  end
  def assign_geoip_city(conn, nil), do: conn

  def assign_geoip_country(conn, %Geolix.Record.Country{name: country, iso_code: code} = _) do
    conn
    |> assign(:geoip_country, country)
    |> assign(:geoip_country_iso, code)
  end
  def assign_geoip_country(conn, nil), do: conn

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
  def is_https(%Plug.Conn{scheme: :https} = _), do: true
  def is_https(%Plug.Conn{} = conn) do
    case get_req_header(conn, "x-forwarded-proto") do
      ["https"] -> true
      _ -> false
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
    |> Tuple.to_list
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

      iex> IpdustWeb.Plugs.IpInfo.hostname({8, 8, 8, 8})
      "google-public-dns-a.google.com"
  """
  def hostname(ip) when is_tuple(ip) do
    case :inet.gethostbyaddr(ip) do
      {:ok, {:hostent, hostname, _, _, _, _}} -> to_string(hostname)
      _ -> nil
    end
  end
end
