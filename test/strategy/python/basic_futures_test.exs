defmodule PuntingTest.Strategy.Isaac.BasicFuturesTest do
  use ExUnit.Case, async: true
  @moduletag :python

  alias Punting.Strategy.Isaac.BasicFutures
    setup do
        PythonPhone.start_link
        {:ok, []}
    end

    test "provides a bet for game" do
        bets = BasicFutures.futures(%{
            "id" => 0,
            "initial" => %{'0' => [1,2], '1' => [0], '2' => [0]}, 
            "available" => %{'0' => [1,2], '1' => [0], '2' => [0]},
            0 => %{},
            "mines" => [1]
        })
        assert !Enum.empty?(bets)
    end

    test "makes moves for game" do
        
    end
end