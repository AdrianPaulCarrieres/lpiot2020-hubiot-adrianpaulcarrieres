defmodule HubiotWeb.CapteurChannel do
  use Phoenix.Channel

  def join("capteur:" <> _, _message, socket) do
    {:ok, socket}
  end

  alias Phoenix.Socket.Broadcast

  def handle_info(%Broadcast{topic: _, event: event, payload: payload}, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end
end
