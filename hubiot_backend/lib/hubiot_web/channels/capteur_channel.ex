defmodule HubiotWeb.CapteurChannel do
  use Phoenix.Channel
  alias Phoenix.Socket.Broadcast

  import Hubiot.PresenceTracker

  def join("capteur:" <> location, _message, socket) do
    # name = socket.assigns.name
    name = "adrian"

    put(location, name)
    {:ok, users} = get(location)

    send(self(), {:after_join, name})
    {:ok, %{users: users}, socket}
  end

  def handle_info(%Broadcast{topic: _, event: event, payload: payload}, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end

  def handle_info({:after_join, name}, socket) do
    broadcast!(socket, "new_user", %{name: name})
    {:noreply, socket}
  end
end
