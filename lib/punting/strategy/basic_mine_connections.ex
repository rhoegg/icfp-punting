defmodule Punting.Strategy.BasicMineConnections do
  def move(game) do
    #right now, you need to modify the defstrruct in lib/punting/player.ex
    #in order to chance strategies.
    get_a_move(game)
  end

  def get_a_move(game) do
    new_game = MineRoutes.onMoveMinePlaysOnly(game)

    if Enum.empty?(new_game["mine_route_map"]) do
      Punting.Logger.log("strategy", "going random route")
      Punting.Strategy.RandomChoice.move(game)
    else
      Punting.Logger.log("strategy", "mine route map:")
      Punting.Logger.log("strategy", inspect(new_game["mine_route_map"]))
      get_first_route(new_game)
    end
  end

  def get_first_route(game) do
    case Map.values(game["mine_route_map"]) |> hd |> hd do
      [_source | []]      -> Punting.Strategy.RandomChoice.move(game)
      [source | targets ] ->  
        IO.inspect(source)
        IO.inspect(targets)
        target = hd(targets)
        Punting.Logger.log("strategy", "source #{source} target #{target}")
        {source, target}
    end

  end


end

