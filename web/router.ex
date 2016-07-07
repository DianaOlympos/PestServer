defmodule PestServer.Router do
  use PestServer.Web, :router
  alias PestServer.AuthController

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/auth" do
    pipe_through :browser
    get "/", AuthController, :index
    get "/callback", AuthController, :callback
    get "/success", AuthController, :success
  end

  scope "/api", PestServer do
    pipe_through :api
  end
end

# client opens web socket to ingest, ingest
# opens web socket and pushes message "auth here",
# client opens said URL,
# ingest is ignoring all messages pushed to it at this time,
#  user completes SSO flow on ingest
#  and the ingest flags that connection as OK,
#  ingest starts passing incoming messages

# [19:55]
# should probably drop the connection after X amount of time
# if it doesn't get authed
