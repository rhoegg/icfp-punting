defmodule Punting.Strategy.CovetMines do
  def move(game) do
    with nil <- grab_each_mine(game),
         nil <- extend_routes(game) do
      nil
    end
  end

  # Stage 1

  defp grab_each_mine(game) do
    sorted_mines =
      game["mines"]
      |> Enum.sort_by(fn mine -> length(game["available"][mine]) end)
    unclaimed_mine =
      sorted_mines
      |> Enum.find(fn mine ->
        available?(mine, game) && not_ours?(mine, game)
      end)
    if is_nil(unclaimed_mine) do
      nil
    else
      sorted_moves =
        game["available"][unclaimed_mine]
        |> Enum.sort_by(fn move -> -length(game["available"][move]) end)
      {unclaimed_mine, hd(sorted_moves)}
    end
  end

  defp available?(site, game) do
    length(game["available"][site]) > 0
  end

  defp not_ours?(site, game) do
    !ours?(site, game)
  end

  # Stage 2

  defp extend_routes(game) do
    starts = Map.keys(game[game["id"]])
    walk_our_routes(game, Enum.map(starts, &[&1]), MapSet.new(starts), [ ])
    |> Enum.sort_by(fn route -> -length(route) end)
    |> Enum.find_value(fn route ->
      Enum.find_value(route, fn site ->
        available = List.wrap(game["available"][site])
        if available == [ ] do
          nil
        else
          {site, hd(available)}
        end
      end)
    end)
  end

  defp walk_our_routes(_game, [ ], _visited, full_routes), do: full_routes
  defp walk_our_routes(
    game,
    [[now | _before] = route | walking],
    visited,
    full_routes
  ) do
    our_steps =
      game["initial"][now]
      |> Enum.filter(fn site ->
        !MapSet.member?(visited, site) && ours?(site, game)
      end)
    if our_steps == [ ] do
      walk_our_routes(game, walking, visited, [route | full_routes])
    else
      new_routes = Enum.map(our_steps, fn site -> [site | route] end)
      walk_our_routes(
        game,
        new_routes ++ walking,
        MapSet.union(visited, MapSet.new(our_steps)),
        full_routes
      )
    end
  end

  # defp available?(source, target, game) do
  #   Enum.member?(game["available"][source], target)
  # end

  defp ours?(site, game) do
    Map.has_key?(game[game["id"]], site)
  end
end
