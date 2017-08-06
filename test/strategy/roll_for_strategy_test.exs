defmodule PuntingTest.Strategy.RollDiceStrategyTest do
  use ExUnit.Case
  alias Punting.Strategy.RollDice
  alias PuntingTest.Strategy.{AlwaysOneTwo,AlwaysSixSeven}

  test "rolls dice to choose strategy" do
      test_seed = :rand.seed({:exrop, [1 | 2]})
      strategy = RollDice.strategy(13, 20, AlwaysSixSeven, AlwaysOneTwo, test_seed)
      do_move = strategy.(:move)

      assert do_move.(nil) == {1, 2}
      assert do_move.(nil) == {6, 7}
      assert do_move.(nil) == {6, 7}
      assert do_move.(nil) == {1, 2}
  end

end
