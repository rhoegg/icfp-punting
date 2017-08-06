defmodule StrategyFunctionalTest do
  use ExUnit.Case

  @moduletag :functional
  @moduletag :strategy

  test "slacker match" do
    game =
      Livegames.list_empty()
      |> Enum.filter( &(Enum.empty?(&1.extensions)) )
      |> Enum.filter( &(&1.map_name == "lambda.json") )
      |> hd
    IO.puts("Found a game with #{game.seats} seats.")

      Range.new(0, game.seats - 1)
      |> Enum.map(fn _n ->
        Task.async(fn ->
          Process.flag(:trap_exit, true)

          go_play(game.port, Punting.Strategy.AlwaysPass)

          receive do
            {:result, _moves, _id, _scores, _state} = result -> result
            _ -> nil
          end
        end)
      end)
      |> Enum.map(fn t -> Task.await(t, :infinity) end)
      |> Enum.filter(fn result -> not is_nil(result) end)
  end

  def go_play(port, strategy) do
    Punting.Player.start_link(
      Punting.OnlineMode,
      mode_arg: port,
      scores:   self(),
      strategy: strategy
    )
  end
end
