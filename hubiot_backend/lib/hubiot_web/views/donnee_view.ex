defmodule HubiotWeb.DonneeView do
  use HubiotWeb, :view
  alias HubiotWeb.DonneeView

  def render("index.json", %{donnees: donnees}) do
    %{data: render_many(donnees, DonneeView, "donnee.json")}
  end

  def render("show.json", %{donnee: donnee}) do
    %{data: render_one(donnee, DonneeView, "donnee.json")}
  end

  def render("donnee.json", %{donnee: donnee}) do
    %{id: donnee.id,
      number: donnee.number,
      location: donnee.location
    }
  end
end
