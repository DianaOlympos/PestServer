defmodule PestServer.Eve do
  @moduledoc """
  An OAuth2 strategy for Eve.
  Based on the OAuth2 strategy for GitHub by Sonny Scroggin
  in https://github.com/scrogson/oauth2_example
  """
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  # Public API

  def new do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: Application.get_env(:pest_server, :client_id),
      client_secret: Application.get_env(:pest_server, :client_secret),
      redirect_uri: Application.get_env(:pest_server, :redirect_uri),
      site: "https://login.eveonline.com",
      authorize_url: "https://login.eveonline.com/oauth/authorize",
      token_url: "https://login.eveonline.com/oauth/token"
    ])
  end

  def authorize_url!(params \\ [])

  def authorize_url!([id | tail]) do
    new()
    |> put_param("state", id)
    |> OAuth2.Client.authorize_url!(tail)
  end

  def authorize_url!(params) do
    new()
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(new(), params, headers)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> put_header("Authorization",
                  "Basic " <> Base.encode64(
                              Application.get_env(
                                :pest_server, :client_id)
                           <> ":"
                           <> Application.get_env(
                              :pest_server, :client_secret)))
    |> AuthCode.get_token(params, headers)
  end
end
