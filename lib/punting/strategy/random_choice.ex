defmodule Punting.Strategy.RandomChoice do
  def move(game) do
    #right now, you need to modify the defstrruct in lib/punting/player.ex
    #in order to change strategies.
    source = Map.keys(game["available"]) 
             |> Enum.filter(fn(y) -> length(game["available"][y]) > 0 end)
             |> Enum.random
    target = game["available"][source] |> Enum.random
    {source, target}
  end
end

