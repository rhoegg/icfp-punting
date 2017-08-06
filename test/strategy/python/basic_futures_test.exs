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
        move = BasicFutures.move(%{
	    "id"=>0,
	    "initial" =>%{'1'=>[2,4], '2'=>[1,5], '3'=>[5,6],
	    	          '4'=>[1,8], '5'=>[3,6,8,9], '6'=>[3,5],
                          '7'=>[8], '8'=>[4,5,7,9], '9'=>[5,8]},
            "available" => %{'1'=>[2,4], '2'=>[1,5], '3'=>[5,6],
	    	          '4'=>[1,8], '5'=>[3,6,8,9], '6'=>[3,5],
                          '7'=>[8], '8'=>[4,5,7,9], '9'=>[5,8]},
            "0" => %{1=>[4], 4=>[1]},
            "futures"=>[[1,9]],
            "mines"=>[1]
	})
        assert !Enum.empty?(move)
    end
end