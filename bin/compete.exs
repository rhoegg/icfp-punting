alias Punting.Strategy.{BuildFromMines,Voyager,GrabMinesWithLeastAvailableSpokes,GrabMinesWithMostAvailableSpokes,RandomChoice,Composite}

defmodule BuildFromMinesOrRandom do
    def move(game) do
        Composite.move(game, [
            BuildFromMines,
            RandomChoice
        ])
    end
end

defmodule VoyagerOrRandom do
    def move(game) do
        Composite.move(game, [
            Voyager,
            RandomChoice
        ])
    end
end

defmodule GrabMinesThenVoyagerThenRandom do
    def move(game) do
        Composite.move(game, [
            GrabMinesForThreeMoves,
            Voyager,
            RandomChoice
        ])
    end
end

defmodule GrabMinesForThreeMoves do
    def use?(%{"turns_taken" => turns_taken}) do
        turns_taken < 3
    end

    def move(game) do
        GrabMinesWithLeastAvailableSpokes.move(game)
    end
end

map = "lambda.json"

game =
  Livegames.list_empty()
  |> Enum.filter( &(Enum.empty?(&1.extensions)) )
  |> Enum.filter( &(&1.map_name == "lambda.json") )
|> hd
if game == nil do
    IO.puts("No empty games for #{map}")
end
IO.puts("Found a game using #{map} with #{game.seats} seats.")
IO.puts("About to play on port #{game.port}")

strategies = [
    BuildFromMinesOrRandom,
    VoyagerOrRandom,
    GrabMinesThenVoyagerThenRandom
]

result =
  Range.new(0, game.seats - 1)
  |> Enum.zip(Stream.concat(strategies, Stream.cycle(List.wrap(RandomChoice))))
  |> Enum.map(fn {n, strategy} = x->
    Task.async(fn ->
      Process.flag(:trap_exit, true)

      Punting.Player.start_link(
        Punting.OnlineMode,
        mode_arg: game.port,
        scores:   self(),
        strategy: strategy || RandomChoice
      )
      IO.puts("Started player #{n} with strategy #{strategy}.")
  
      receive do
        {:result, _moves, _id, _scores, _state} = result -> result
        _ -> nil
      end
    end)
  end)
|> Enum.map(fn t -> Task.await(t, :infinity) end)
|> Enum.filter(fn result -> not is_nil(result) end)

IO.inspect(result)
