defmodule PuntingTest do
  use ExUnit.Case
  doctest Punting

  test "greets the world" do
    assert Punting.hello() == :world
  end
end
