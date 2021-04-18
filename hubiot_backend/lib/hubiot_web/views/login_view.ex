defmodule HubiotWeb.LoginView do
  use HubiotWeb, :view

  def render("token.json", %{token: token}) do
    %{token: token}
  end

end
