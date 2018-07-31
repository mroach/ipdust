defmodule IpdustWeb.PageView do
  use IpdustWeb, :view

  def render("json.json", params) do
    geoip = case params.geoip_success do
      true -> %{  country: params[:geoip_country], city: params[:geoip_city] }
      _ -> %{}
    end

    %{
      ip: params.remote_ip,
      https: params.is_https,
      host: params.hostname,
      server_time: params.server_time,
      headers: params.headers |> Enum.into(%{})
    } |> Map.merge(geoip)
  end

  @doc """
  Formats a DateTime, Date, or Time object with sensible defaults

  ## Examples
      iex> {:ok, dt, _} = DateTime.from_iso8601("2015-01-23T23:50:07Z")
      ...> IpdustWeb.PageView.date_time_format(dt)
      "23 Jan 2015 23:50 Etc/UTC"


      iex> IpdustWeb.PageView.date_time_format(~T[09:23:19])
      "09:23:19"

      iex> IpdustWeb.PageView.date_time_format(~T[22:01:00])
      "22:01:00"
  """
  def date_time_format(date = %DateTime{}), do: date_time_format(date, "%d %b %Y %H:%M %Z")
  def date_time_format(date = %Date{}), do: date_time_format(date, "%d %b %Y")
  def date_time_format(date = %Time{}), do: date_time_format(date, "%H:%M:%S")

  @doc """
  Formats a DateTime, Date, or Time with the given format

  ### Examples
    iex> {:ok, dt, _} = DateTime.from_iso8601("2015-01-23T23:50:07Z")
    ...> IpdustWeb.PageView.date_time_format(dt, "%F")
    "2015-01-23"

    iex> IpdustWeb.PageView.date_time_format(~D[2018-07-23], "%F")
    "2018-07-23"

    iex> IpdustWeb.PageView.date_time_format(~D[2018-07-23], "%d.%m.%Y")
    "23.07.2018"

    iex> IpdustWeb.PageView.date_time_format(~T[22:01:00], "%I:%M %p")
    "10:01 PM"
  """
  def date_time_format(date = %DateTime{}, format), do: strftime(date, format)
  def date_time_format(date = %Date{}, format), do: strftime(date, format)
  def date_time_format(date = %Time{}, format), do: strftime(date, format)

  defp strftime(date, format) do
    case Timex.format(date, format, :strftime) do
      {:ok, formatted} -> formatted
      _ -> to_string(date)
    end
  end
end
