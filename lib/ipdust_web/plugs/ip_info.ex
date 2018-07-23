defmodule IpdustWeb.Plugs.IpInfo do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    conn
    |> assign(:remote_ip, ip_to_string(conn.remote_ip))
    |> assign(:hostname, hostname(conn.remote_ip))
    |> assign(:server_time, DateTime.utc_now)
    |> assign(:headers, conn.req_headers)
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
