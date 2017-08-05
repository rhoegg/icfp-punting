defmodule Punting.Strategy.BasicMineConnections do
  def move(game) do
    #right now, you need to modify the defstrruct in lib/punting/player.ex
    #in order to chance strategies.
    get_first_route(game)
  end

  def get_first_route(game) do
    IO.inspect(Map.keys(game))
    IO.puts("id is #{game["id"]}")
    IO.inspect(game[game["id"]])
    new_game = MineRoutes.onMoveMinePlaysOnly(game)

    if Enum.empty?(new_game["mine_route_map"]) do
      IO.puts("going with random")
      Punting.Strategy.RandomChoice.move(game)
    else
      [source | targets] = Map.values(new_game["mine_route_map"]) |> hd |> hd
      target = hd(targets)
      IO.puts("source #{source}, target #{target}")
      {source, target}
    end
  end

end

