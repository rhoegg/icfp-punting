defmodule Punting.Strategy.BasicMineConnections do
  def move(game) do
    #right now, you need to modify the defstrruct in lib/punting/player.ex
    #in order to chance strategies.
    get_first_route(game)
  end

  def get_first_route(game) do
    new_game = MineRoutes.onMoveMinePlaysOnly(game)

    if Enum.empty?(new_game["mine_route_map"]) do
      Punting.Logger.log("strategy", "going random route")
      Punting.Strategy.RandomChoice.move(game)
    else
      Punting.Logger.log("strategy", "other route map:")
      Punting.Logger.log("strategy", inspect(new_game["other_routes"]))
      Punting.Logger.log("strategy", "mine route map:")
      Punting.Logger.log("strategy", inspect(new_game["mine_route_map"]))
      [source | targets] = Map.values(new_game["mine_route_map"]) |> hd |> hd
      target = hd(targets)
      Punting.Logger.log("strategy", "source #{source} target #{target}")
      {source, target}
    end
  end

end

