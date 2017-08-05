defmodule DataStructure do
  @moduledoc """
  Primary Datastructure for keeping track of the game state

  ```
  %{
    "initial"     => intial state of the game,
    "available"   => available moves,
    "total_turns" => Enum.count(rivers) / punters,
    "turns_taken" => turn counter,
    "mines"       => mine locations,
    "id"          => punter id
    x             => other punters moves structure
  }
  ```

  Initial state, available state, and the punter's moves structure
  all follow the same pattern:

  `%{ point => [ connected points ] }`

  When a move is made, connected points are removed from the available moves
  key, and are added to the `x` punter's data structure
  """


  @doc """
  Handles processing of messaging, supports {:setup, id, punters, game}
  and {:move, moves, state}
  """
  def process({:setup, id, punters, %{"rivers" => rivers, "mines" => mines}}) do
    initial =
      rivers
      |> Enum.map_reduce(%{}, &add_river/2)
      |> elem(1)
    total_rivers = Enum.count(rivers)
    max_turns = total_rivers / punters

   %{
      "initial"     => initial,
      "available"   => initial,
      "total_turns" => max_turns,
      "turns_taken" => 0,
      "mines"       => mines,
      "id"          => id,
      "number_of_punters" => punters,
      "total_rivers" => total_rivers,
    } |> Map.merge(MineRoutes.start(mines, initial, max_turns))
  end
  def process({:move, moves, state}) do
    moves
    |> Enum.map_reduce(state, &do_move/2)
    |> elem(1)
  end

  defp add_river(river, nil) do
    add_river(river, %{})
  end
  defp add_river(%{"source" => source, "target" => target} = river, acc) do
    acc =
      Map.update(acc, source, [target], fn x -> [target | x ] end)
      |> Map.update(target, [source], fn x -> [source | x ] end)

    {river, acc}
  end

  defp do_move(%{"claim" => %{"punter" => punter} = move}, acc) do
    acc =
      acc
      |> Map.put("available", remove_move(move, acc["available"]))
      |> Map.put("turns_taken", (acc["turns_taken"] + 1))
      |> Map.put(punter, add_river(move, acc[punter]) |> elem(1))

    {move, acc}
  end
  defp do_move(%{"pass" => %{"punter" => _punter}} = move, acc) do
    {move, acc}
  end

  defp remove_move(%{"source" => source, "target" => target}, acc) do
    acc
    |> Map.put(target, List.delete(acc[target], source))
    |> Map.put(source, List.delete(acc[source], target))
  end
end
