defmodule PestServer.Router do
  use PestServer.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth" do
    get "/", AuthController, :index
    get "/callback", AuthController, :callback
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
