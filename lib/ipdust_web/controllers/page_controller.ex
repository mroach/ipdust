defmodule IpdustWeb.PageController do
  use IpdustWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def json(conn, _params) do
    render conn, "json.json"
  end
end
