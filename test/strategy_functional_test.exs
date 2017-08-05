defmodule StrategyFunctionalTest do
  use ExUnit.Case
  
  @moduletag :functional
  @moduletag :strategy

  test "slacker match" do
    game = hd(Livegames.list_empty()
        |> Enum.filter( &(&1.map_name == "lambda.json") ))
    IO.puts("Found a game with #{game.seats} seats.")
    Range.new(0, game.seats)
    |> Enum.each(fn (n) -> 
        Task.async( fn -> go_play(n, game.port, Punting.Strategy.AlwaysPass) end )
    end)

    result = receive do
        {:stop, info} -> info
    end

    #IO.inspect(result)
    flunk("why am I using a test?")
  end

  def go_play(n, port, strategy) do
      Punting.Player.start_link(Punting.OnlineMode, mode_arg: port, scores: self())
  end
end
