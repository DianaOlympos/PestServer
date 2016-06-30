defmodule PestServer.CharacterDetails do
  use HTTPoison.Base

  def fetch_user_details (access_token) do
    "https://login.eveonline.com/oauth/verify/"
    |> HTTPoison.get([{"Authorization", "Bearer "<>access_token}])
    |> handle_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body}}) do
    Poison.decode(body)
  end

  defp handle_response({:error,%HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end
