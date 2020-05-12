defmodule IpdustWeb.Router do
  use IpdustWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :put_secure_browser_headers
    plug IpdustWeb.Plugs.IpInfo
  end

  scope "/", IpdustWeb do
    # Use the default browser stack
    pipe_through :browser

    get "/", PageController, :index
    get "/net", PageController, :net
    get "/json", PageController, :json
    get "/ip", PageController, :ip
  end
end
