defmodule Graph do
 def process({:setup, id, punters, %{"rivers" => rivers, "mines" => mines}}) do
    initial =
      rivers
      |> Enum.map_reduce(%{}, &add_river/2)
      |> elem(1)

   %{
      "initial"     => initial,
      "available"   => initial,
      "total_turns" => Enum.count(rivers) / punters,
      "turns_taken" => 0,
      "mines"       => mines,
      "id"          => id
    }
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
