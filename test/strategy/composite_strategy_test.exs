defmodule PuntingTest.Strategy.CompositeStrategyTest do
  use ExUnit.Case
  alias Punting.Strategy.Composite
  alias PuntingTest.Strategy.{AlwaysOneTwo, NeverTwoThree, NoUseFunction}

  test "uses one strategy" do
    move = Composite.move(nil,
        AlwaysOneTwo)
    assert move == {1, 2}
  end

  test "does not use strategy unless use? matches" do
    move = Composite.move(nil,
        NeverTwoThree)
    assert move == nil
  end

  test "no use? function means always" do
    move = Composite.move(nil,
        NoUseFunction)
    assert move == {42, 43}
  end

  test "uses first that matches" do
    move = Composite.move(nil,
        [
            NeverTwoThree,
            AlwaysOneTwo,
            NoUseFunction
        ])
    assert move == {1, 2}
  end

  test "uses first that matches and returns a move" do
    move = Composite.move(nil,
        [
            Punting.Strategy.AlwaysPass,
            AlwaysOneTwo
        ])
    assert move == {1, 2}
  end
end