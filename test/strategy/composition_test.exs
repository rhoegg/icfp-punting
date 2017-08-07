alias Punting.Strategy.Compose
alias PuntingTest.Strategy.{AlwaysOneTwo,AlwaysSixSeven}
defmodule PuntingTest.Strategy.CompositionTest do
    use ExUnit.Case
    
    test "own fewer than n mines" do
        game1 = %{
            "mines" => [1, 2, 3, 4, 5],
            "id" => 1,
            1 => %{
                1 => [2, 6, 9, 10],
                2 => [1],
                4 => [10],
                6 => [1],
                9 => [1],
                10 => [1]
            }
        }

        game2 = %{
            "mines" => [6, 7, 8, 9, 10, 11],
            "id" => 2,
            2 => %{
                1 => [6],
                6 => [1],
                7 => [12],
                9 => [13],
                10 => [14],
                11 => [15],
                12 => [7],
                13 => [9],
                14 => [10],
                15 => [11]
            }
        }

        fewer_than_2 = Compose.own_fewer_mines(AlwaysOneTwo, 2)
        fewer_than_4 = Compose.own_fewer_mines(AlwaysSixSeven, 4)

        assert fewer_than_2.(:move).(game1) == nil
        assert fewer_than_2.(:move).(game2) == nil
        assert fewer_than_4.(:move).(game1) == {6, 7}
        assert fewer_than_4.(:move).(game2) == nil
    end

end