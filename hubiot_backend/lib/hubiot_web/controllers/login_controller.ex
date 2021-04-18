defmodule HubiotWeb.LoginController do
  use HubiotWeb, :controller

  alias Hubiot.Accounts

  action_fallback HubiotWeb.FallbackController

  def login(conn, %{"email" => email, "password" => password} = user_params) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = login_user(user, user_params) |> Base.encode64()

      conn
      |> put_status(:ok)
      |> render("token.json", token: token)
    end
  end

  defp login_user(user, _params) do
    Accounts.generate_user_session_token(user)
  end
end
