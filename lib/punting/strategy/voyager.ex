defmodule Punting.Strategy.Voyager do
    def move(%{"id" => id, "available" => available} = game) do
        game
        |> Map.get(id, %{})
        |> find_trail(available)
        |> make_move(available)
    end

    def make_move(nil, _), do: nil
    def make_move([], _), do: nil
    def make_move(trail, available) do
        x = trail |> hd |> hd
        if available_river?(x, available) do
            {x, Map.get(available, x) |> hd}
        else
            nil
        end
    end

    def find_trail(moves, available) do
        find_trails(moves)
        |> Enum.filter(fn trail ->
            available_river?(hd(trail), available)
        end)
    end

    defp available_river?(p, available) do
        moves = Map.get(available, p)
        moves && ! Enum.empty?(moves)
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