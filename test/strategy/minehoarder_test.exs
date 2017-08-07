defmodule PuntingTest.Strategy.MineHoarderTest do
    alias Punting.Strategy.MineHoarder
    use ExUnit.Case

    test "plays river on Mine with least available" do
        game = %{
            "available" => %{
                1 => [5, 6, 11, 14, 21, 28, 29],
            #   4 (none available)
                5 => [1],
                6 => [1, 13, 17],
                7 => [13, 18, 19, 20],
                11 => [1],
                13 => [6, 7],
                14 => [1],
                17 => [6],
                18 => [7],
                19 => [7],
                20 => [7],
                21 => [1],
                28 => [1],
                29 => [1],
            },
            "id" => 3,
            "mines" => [1, 4, 6, 7]
        }

        move = case MineHoarder.move(game) do
            {x, 6} -> {6, x}
            any -> any
        end

        assert {6, _} = move
    end

    test "does nothing if mines are full" do
        game = %{
            "available" => %{
            #   1 (none available)
            #   4 (none available)
                5 => [11],
            #   6 (none available)
            #   7 (none available)
                11 => [5],
                13 => [14, 17],
                14 => [13],
                17 => [13]
            },
            "id" => 3,
            "mines" => [1, 4, 6, 7]
        }
        assert MineHoarder.move(game) == nil
    end
end