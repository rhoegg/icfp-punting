defmodule CompositeStrategyTest do
  use ExUnit.Case

  test "uses one strategy" do
    move = Punting.Strategy.Composite.move(nil,
        PuntingTest.Strategy.AlwaysOneTwo)
    assert move == {1, 2}
  end

  test "does not use strategy unless use? matches" do
    move = Punting.Strategy.Composite.move(nil,
        PuntingTest.Strategy.NeverTwoThree)
    assert move == nil
  end

  test "no use? function means always" do
    move = Punting.Strategy.Composite.move(nil,
        PuntingTest.Strategy.NoUseFunction)
    assert move == {42, 43}
  end

  test "uses first that matches" do
    move = Punting.Strategy.Composite.move(nil,
        [
            PuntingTest.Strategy.NeverTwoThree,
            PuntingTest.Strategy.AlwaysOneTwo,
            PuntingTest.Strategy.NoUseFunction
        ])
    assert move == {1, 2}
  end

  test "uses first that matches and returns a move" do
    move = Punting.Strategy.Composite.move(nil,
        [
            Punting.Strategy.AlwaysPass,
            PuntingTest.Strategy.AlwaysOneTwo
        ])
    assert move == {1, 2}
  end
end

defmodule PuntingTest.Strategy.NeverTwoThree do
  def use?(_game) do
    false
  end

  def move(_game) do
    {2, 3}
  end
end

defmodule PuntingTest.Strategy.AlwaysOneTwo do
  def use?(_game) do
    true
  end

  def move(_game) do
    {1, 2}
  end
end

defmodule PuntingTest.Strategy.NoUseFunction do
  def move(_game) do
    {42, 43}
  end
end