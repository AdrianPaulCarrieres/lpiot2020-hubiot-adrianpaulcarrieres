defmodule HubiotWeb.CapteurChannel do
  use Phoenix.Channel
  alias Phoenix.Socket.Broadcast

  def join("capteur:" <> _, _message, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(%Broadcast{topic: _, event: event, payload: payload}, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    #broadcast!(socket, "new_student", %{game: game})
  end
end
