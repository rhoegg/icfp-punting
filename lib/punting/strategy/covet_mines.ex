defmodule Punting.Strategy.CovetMines do
  def move(game) do
    with nil <- grab_each_mine(game),
         nil <- connect_mines(game),
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

  defp connect_mines(game) do
    move =
      game["trees_with_mine_bookends"]
      |> Enum.find_value(fn route ->
        route
        |> Enum.chunk_every(2, 1)
        |> Enum.find(fn
          [s1, s2] ->
            available?(s1, s2, game) && (ours?(s1, game) || ours?(s2, game))
          [_n] ->
            false
        end)
      end)
    if is_nil(move) do
      nil
    else
      List.to_tuple(move)
    end
  end

  defp available?(source, target, game) do
    Enum.member?(game["available"][source], target)
  end

  defp ours?(site, game) do
    Map.has_key?(game[game["id"]], site)
  end

  # Stage 3

  defp extend_routes(game) do
    walk_our_routes(game, Enum.map(game["mines"], &[&1]), [ ])
    |> Enum.sort_by(fn route -> -length(route) end)
    |> Enum.find_value(fn [site | _route] ->
      choices = List.wrap(game["available"][site])
      if choices == [ ] do
        nil
      else
        {site, hd(choices)}
      end
    end)
  end

  defp walk_our_routes(_game, [ ], full_routes), do: full_routes
  defp walk_our_routes(
    game,
    [[now | _before] = route | walking],
    full_routes
  ) do
    our_steps =
      game["available"][now]
      |> Enum.filter(fn site -> ours?(site, game) end)
    if our_steps == [ ] do
      walk_our_routes(game, walking, [route | full_routes])
    else
      new_routes = Enum.map(our_steps, fn site -> [site | route] end)
      walk_our_routes(game, walking ++ new_routes, full_routes)
    end
  end
end
