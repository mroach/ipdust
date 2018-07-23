defmodule IpdustWeb.Router do
  use IpdustWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :put_secure_browser_headers
    plug IpdustWeb.Plugs.IpInfo
  end

  scope "/", IpdustWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/json", PageController, :json
  end
end
