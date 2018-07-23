defmodule IpdustWeb.PageController do
  use IpdustWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
