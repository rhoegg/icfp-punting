defmodule Punting.DataStructure.ScoreKeeper do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, %{})
  end

  def scores(pid) do
    GenServer.call(pid, :score)
  end

  def make_id(source, target) do
    [source,target]
    |> Enum.sort
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join("-")
  end

  def get_score(pid, id) do
    GenServer.call(pid, {:score, id})
  end

  def add_score(pid, mine_route, starting_mine) do
    GenServer.cast(pid, {:update_score, mine_route, starting_mine})
  end

  def handle_call(:score, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:score, id}, _from, state) do
    {:reply, Map.get(state,id), state}
  end

  def handle_cast({:update_score, [ending_site | _tail] = mine_route, starting_mine}, state) do
    route_id =
      [starting_mine, ending_site]
      |> Enum.sort
      |> Enum.map(&Integer.to_string/1)
      |> Enum.join("-")

    existing_score = Map.get(state, route_id)
    new_score = :math.pow(Enum.count(mine_route),2)

    {:noreply, update_state(route_id, new_score, existing_score, state)}
  end

  defp update_state(route_id, new_score, nil, state),
    do: Map.put(state, route_id, new_score)
  defp update_state(route_id, new_score, existing_score, state) when new_score <= existing_score,
    do: Map.put(state, route_id, new_score)
  defp update_state(_route_id, _new_score, _existing_score, state),
    do: state
end
