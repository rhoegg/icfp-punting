defmodule Punting.Strategy.BasicMineConnections do
  def move(game) do
    #right now, you need to modify the defstrruct in lib/punting/player.ex
    #in order to chance strategies.
    get_first_route(game)
  end

  def get_first_route(game) do
    new_game = MineRoutes.onMoveMinePlaysOnly(game)

    if Enum.empty?(new_game["mine_route_map"]) do
      Punting.Strategy.RandomChoice.move(game)
    else
      [source | targets] = Map.values(new_game["mine_route_map"]) |> hd |> hd
      target = hd(targets)
      {source, target}
    end
  end

end

