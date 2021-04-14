defmodule Hubiot.PresenceTracker do
  use GenServer

  #Public api
  def start(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def put(location, name) do
    GenServer.call(__MODULE__, {:put, location, name})
  end

  def get(location) do
    GenServer.call(__MODULE__, {:get, location})
  end

  def delete(location, name) do
    GenServer.call(__MODULE__, {:delete, location, name})
  end

  # Callbacks
  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:put, location, name}, _from, state) do
    case Map.get(state, location) do
      nil ->
        state = Map.put(state, location, [name])
        {:reply, {:ok, name}, state}
      users when is_list(users) ->
        users = users ++ [name]
        state = Map.put(state, location, users)
        {:reply, {:ok, name}, state}
    end
  end


end
