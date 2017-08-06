defmodule Punting.Strategy.Voyager do
    def move(%{"id" => id, "available" => available} = game) do
        game
        |> Map.get(id, %{})
        |> find_longest_trail
        |> make_move(available)
    end

    def make_move([], _), do: nil
    def make_move(trail, available) do
        x = trail |> hd |> hd
        {x, Map.get(available, x) |> hd}
    end

    def find_longest_trail(moves) do
        find_trails(moves)
    end

    def find_trails(moves) do
        trails = moves
        |> Enum.flat_map(fn {x, connected} ->
            Enum.map(connected, fn y -> [y, x] end)
        end)
        find_trails(moves, trails)
    end

    def find_trails(moves, trails) do
        new_trails = trails
        |> Enum.flat_map(fn trail ->
            Map.get(moves, hd(trail))
            |> Enum.map(fn y -> [y | trail] end)
        end)
        |> Enum.filter(fn [head | trail] -> ! Enum.member?(trail, head) end)
        if new_trails == [], do: trails, else: find_trails(moves, new_trails)
    end
end