defmodule HubiotWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:capteur", _message, socket) do
    {:ok, socket}
  end

  alias Phoenix.Socket.Broadcast

  def handle_info(%Broadcast{topic: _, event: event, payload: payload}, socket) do
    IO.inspect(payload, label: "hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
    push(socket, event, payload)
    {:noreply, socket}
  end

  def handle_info(_, socket) do
    IO.inspect("payload", label: "hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
    push(socket, "event", "payload")
    {:noreply, socket}
  end
end
