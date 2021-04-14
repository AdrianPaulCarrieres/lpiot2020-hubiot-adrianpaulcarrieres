defmodule Hubiot.PresenceTracker do
  use GenServer

  # Public api
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Put name to location
  """
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

  @impl true
  def handle_call({:get, location}, _from, state) do
    users = Map.get(state, location)
    {:reply, {:ok, users}, state}
  end

  @impl true
  def handle_call({:delete, location, name}, _from, state) do
    with users when is_list(users) <- Map.get(state, location),
         users when users != [] <- List.delete(users, name) do
      state = Map.put(state, location, users)
      {:reply, {:ok, name}, state}
    else
      nil ->
        {:reply, {:error, "Location not found"}, state}
      [] ->
        state = Map.delete(state, location)
        {:reply, :no_users_left, state}
    end
  end
end
