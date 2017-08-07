defmodule Punting.Strategy.MineHoarder do
    def move(game) do
        available = Map.get(game, "available")
        
        river_lists = game
        |> Map.get("mines")
        |> Enum.map(fn mine -> 
            {mine, Map.get(available, mine, [])}
        end)
        |> Enum.filter( fn {_, spokes} -> length(spokes) > 0 end )

        if Enum.empty?(river_lists) do
            nil
        else
            {mine, rivers} = river_lists
            |> Enum.min_by(fn {_, spokes} -> length(spokes) end)

            rivers
            |> Enum.shuffle
            |> Enum.map(fn y -> {mine, y} end)
            |> hd
        end
    end
end