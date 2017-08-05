defmodule PuntingTest.Strategy.RollDiceStrategyTest do
  use ExUnit.Case
  alias Punting.Strategy.RollDice
  alias PuntingTest.Strategy.{AlwaysOneTwo,AlwaysSixSeven}
  
  test "rolls dice to choose strategy" do
      calcMove = roll4d20( AlwaysOneTwo, AlwaysSixSeven )

      loadDice(3)
      assert calcMove.(nil) == {1, 2}
      loadDice(1)
      assert calcMove.(nil) == {1, 2}
      loadDice(7)
      assert calcMove.(nil) == {6, 7}
      loadDice(20)
      assert calcMove.(nil) == {6, 7}
  end

  def roll4d20(strategy1, strategy2) do
      &(RollDice.move(&1, 4, 20, strategy1, strategy2))
  end

  def loadDice(result) do
      Application.put_env(:punting, :next_dice_roll, result)
  end
end
