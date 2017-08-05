defmodule Punting.Strategy.RandomChoice do
  def move(game) do
    #right now, you need to modify the defstrruct in lib/punting/player.ex
    #in order to chance strategies.
    IO.puts("game:")
    IO.inspect(game)
    source = Map.keys(game["available"]) 
    |> Enum.filter(fn(y) -> length(game["available"][y]) > 0 end)
    |> Enum.random
    IO.puts("available:")
    IO.inspect(game["available"][source])
    target = game["available"][source] |> Enum.random
    IO.puts("source #{source}, target #{target}")
    {source, target}
  end
end

