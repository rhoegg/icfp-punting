defmodule Punting.Strategy.BackToTheFuture do
  alias Punting.Strategy.{Composite, Voyager, RandomChoice}

  def futures(game) do
    goal = div(trunc(game["total_turns"]), 3)
    future =
      game["initial"]
      |> Map.keys
      |> Enum.shuffle
      |> Enum.find_value(fn site ->
        Enum.find_value(game["mines"], fn mine ->
          shortest = pathfind(game, mine, site)
          if shortest && length(shortest) >= goal do
            shortest
          else
            nil
          end
        end)
      end)
    [{:lists.last(future), hd(future)}]
  end

  def move(game) do
    find_future(game) || Composite.move(game, [Voyager, RandomChoice])
  end

  defp find_future(game) do
    if game["futures"] != [ ] &&
      !Map.has_key?(game[game["id"]], elem(hd(game["futures"]), 1)) do
      {mine, site}      = hd(game["futures"])
      futures           = pathfind(game, site, mine)
      river_we_dont_own =
        futures
        |> Enum.chunk_every(2, 1)
        |> Enum.find(fn
        [s1, s2] ->
          game[game["id"]][s1]
          |> List.wrap
          |> Enum.member?(s2)
          |> Kernel.!
        [_n] ->
          false
      end)
      if is_nil(river_we_dont_own) do
        nil
      else
        List.to_tuple(river_we_dont_own)
      end
    else
      nil
    end
  end

  defp pathfind(_game, finish, finish) do
    [finish]
  end
  defp pathfind(game, start, finish) do
    walk_path(game, [[start]], MapSet.new, finish)
  end

  defp walk_path(_game, [ ], _visited, _finish), do: nil
  defp walk_path(
    game,
    [[current | _sites] = path | paths],
    visited,
    finish
  ) do
    steps =
      game["ours_or_available"][current]
      |> Enum.reject(fn site -> MapSet.member?(visited, site) end)
    if Enum.member?(steps, finish) do
      [finish | path]
    else
      new_paths =
        steps
        |> Enum.map(fn step -> [step | path] end)
      walk_path(
        game,
        paths ++ new_paths,
        MapSet.union(visited, MapSet.new(steps)),
        finish
      )
    end
  end
end
