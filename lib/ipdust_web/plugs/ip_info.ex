defmodule IpdustWeb.Plugs.IpInfo do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    remote_ip = find_remote_ip(conn)
    conn
    |> assign(:remote_ip, ip_to_string(remote_ip))
    |> assign(:hostname, hostname(remote_ip))
    |> assign(:is_https, is_https(conn))
    |> assign(:server_time, DateTime.utc_now)
    |> assign(:headers, conn.req_headers)
  end

  @doc """
    Prefer the IP address in the X-Real-IP HTTP header as the app may be sitting
    behind an nginx proxy

  ## Examples
      iex> %Plug.Conn{remote_ip: "127.0.0.1"}
      ...> |> Plug.Conn.put_req_header("x-real-ip", "24.34.153.229")
      ...> |> IpdustWeb.Plugs.IpInfo.find_remote_ip
      {24,34,153,229}
  """
  def find_remote_ip(%Plug.Conn{} = conn) do
    case get_req_header(conn, "x-real-ip") do
      [ip] -> ip_from_string(ip)
      _ -> conn.remote_ip
    end
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
