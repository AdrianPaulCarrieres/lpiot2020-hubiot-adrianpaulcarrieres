defmodule Capteur.Server do
  use GenServer

  # Public API
  def start_link(location) do
    GenServer.start_link(__MODULE__, location: location)
  end

  @impl true
  def init(opts) do
    [location: location] = opts
    Process.send_after(self(), {:send, nil}, 1)

    {:ok, %{location: location}}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  # Callbacks

  @impl true
  def handle_info({:send, _info}, state = %{location: location}) do
    data = Enum.random(1..100)

    Req.post!(
      "http://127.0.0.1:4000/api/donnees",
      {:json, %{donnee: %{value: data, location: location}}}
    )

    Process.send_after(self(), {:send, nil}, 1000)

    {:noreply, state}
  end
end
