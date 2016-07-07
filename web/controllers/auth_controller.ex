defmodule PestServer.AuthController do
  use PestServer.Web, :controller
  alias PestServer.UserDetails

  def index(conn, %{"id"=>id}) do
    redirect conn, external: PestServer.Eve.authorize_url!([id])
  end

  def index(conn, _params) do
    redirect conn, external: PestServer.Eve.authorize_url!()
  end

  def callback(conn, %{"code" => code, "state"=> id}) do
    token = PestServer.Eve.get_token!(code: code)

    conn
    |> authenticate_char(token, id)
    |> redirect(to: "/auth/success")
  end

  def success(conn, _params) do
    text conn, "Success"
  end

  defp authenticate_char(conn, token, id) do

    case PestServer.CharacterDetails.fetch_user_details(token.access_token) do
      {:ok, char_details} -> user = %UserDetails{
                              id: char_details["CharacterID"],
                              name: char_details["CharacterName"]}
                     PestServer.Client.logged(id)
                     conn
                     |> put_flash(:info, char_details["CharacterName"]<>" logged in succesfully")
      {:error, _reason} -> conn
                          |> put_flash(:info, "An error happened during your authentication")
    end
  end
end