defmodule HubiotWeb.CapteurChannel do
  use Phoenix.Channel
  alias Phoenix.Socket.Broadcast

  alias Hubiot.PresenceTracker

  def join("capteur:" <> location, _message, socket) do
    name = socket.assigns.name

    {:ok, users} = PresenceTracker.get(location)
    PresenceTracker.put(location, name)

    send(self(), {:after_join, name})
    {:ok, %{users: users}, socket}
  end

  def handle_info(%Broadcast{topic: _, event: event, payload: payload}, socket) do
    IO.inspect(payload, label: "capteur_channel.ex line 20")
    push(socket, event, payload)
    {:noreply, socket}
  end

  def handle_info({:after_join, name}, socket) do
    broadcast!(socket, "user_joined", %{name: name})
    {:noreply, socket}
  end

  def terminate(_reason, %Phoenix.Socket{topic: topic} = socket) do
    "capteur:" <> location = topic
    name = socket.assigns.name

    PresenceTracker.delete(location, name)

    broadcast!(socket, "user_left", %{name: name})
  end
end
