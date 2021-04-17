defmodule HubiotWeb.DonneeController do
  use HubiotWeb, :controller

  alias Hubiot.Iot
  alias Hubiot.Iot.Donnee

  action_fallback HubiotWeb.FallbackController

  def index(conn, _params) do
    donnees = Iot.list_donnees()
    render(conn, "index.json", donnees: donnees)
  end

  def create(conn, %{"donnee" => donnee_params}) do
    with {:ok, %Donnee{location: location} = donnee} <- Iot.create_donnee(donnee_params) do
      IO.inspect("capteur:#{location}")
      HubiotWeb.Endpoint.broadcast!("capteur:#{location}", "new_data", %{msg: donnee})

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.donnee_path(conn, :show, donnee))
      |> render("show.json", donnee: donnee)
    end
  end

  def show(conn, %{"id" => id}) do
    donnee = Iot.get_donnee!(id)
    render(conn, "show.json", donnee: donnee)
  end

  def update(conn, %{"id" => id, "donnee" => donnee_params}) do
    donnee = Iot.get_donnee!(id)

    with {:ok, %Donnee{} = donnee} <- Iot.update_donnee(donnee, donnee_params) do
      render(conn, "show.json", donnee: donnee)
    end
  end

  def delete(conn, %{"id" => id}) do
    donnee = Iot.get_donnee!(id)

    with {:ok, %Donnee{}} <- Iot.delete_donnee(donnee) do
      send_resp(conn, :no_content, "")
    end
  end
end
