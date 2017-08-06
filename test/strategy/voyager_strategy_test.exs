defmodule PuntingTest.Strategy.VoyagerTest do
  use ExUnit.Case
  alias Punting.Strategy.Voyager

  test "passes first move" do
      game = %{
        "id" => 23,
        "available" => %{},
        23 => %{}
      }
      assert Voyager.move(game) == nil
  end

  test "makes longest trail longer" do
    game = %{
      "id" => 23,
      "mines" => [1, 3],
      "available" => %{
        1 => [11],
        18 => [10],
        10 => [12, 18],
        11 => [1, 13],
        13 => [11],
        12 => [10]
        },
      23 => %{
        1 => [2],
        2 => [1],
        3 => [4, 7],
        4 => [3, 7],
        7 => [4, 3, 18],
        18 => [7]
      }
    }
    assert Voyager.move(game) == {18, 10}
  end
end
