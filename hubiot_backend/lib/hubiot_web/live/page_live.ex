defmodule HubiotWeb.PageLive do
  use HubiotWeb, :live_view

  alias Hubiot.Iot

  @impl true
  def mount(_params, _session, socket) do
    locations =
      Iot.list_locations()
      |> Enum.sort(:asc)

    location = Enum.at(locations, 0) || "No location registered"
    code = generate_qr_code(location)
    {:ok, assign(socket, location: location, code: code, locations: locations)}
  end

  @impl true
  def handle_event("location_selected", %{"location" => location}, socket) do
    locations =
      Iot.list_locations()
      |> Enum.sort(:asc)

    code = generate_qr_code(location)
    {:noreply, assign(socket, location: location, code: code, locations: locations)}
  end

  defp selected_attr(country, country),
    do: "selected=\"selected\""

  defp selected_attr(_, _), do: ""

  defp generate_qr_code(content) do
    content
    |> EQRCode.encode()
    |> EQRCode.png()
    |> Base.encode64()
  end
end
