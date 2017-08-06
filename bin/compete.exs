alias Punting.Strategy.{BuildFromMines,Voyager,GrabMinesWithLeastAvailableSpokes,GrabMinesWithMostAvailableSpokes,RollDice,RandomChoice,Composite}

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
            Compete.first_n_turns(GrabMinesWithLeastAvailableSpokes, 5),
            Voyager,
            RandomChoice
        ])
    end
end

defmodule Compete do
    def grab_mines_then_roll_voyager_vs_build() do
        grab_turns = :rand.uniform(6)
        target = :rand.uniform(6)
        IO.puts("Grabbing for #{grab_turns} turns then rolling for #{target}")
        fn :move ->
            fn game ->
                Composite.move(game, [
                    first_n_turns(GrabMinesWithLeastAvailableSpokes, grab_turns),
                    roll_d6(target, Voyager, BuildFromMines),
                    RandomChoice
                ])
            end
        end
    end

    def roll_d6(target, win_strategy, lose_strategy) do
        RollDice.strategy(target, 6, win_strategy, lose_strategy)
    end

    def first_n_turns(strategy, n) do
        fn :move ->
            fn(%{"turns_taken" => turns} = game) ->
                if turns < n, do: resolve(strategy).(game), else: nil
            end
        end
    end

    defp resolve(strategy) when is_function(strategy) do
        strategy.(:move)
    end

    defp resolve(strategy) when is_atom(strategy) do
        fn game -> strategy.move(game) end
    end
end


{options, _, _} = OptionParser.parse(System.argv, aliases: [m: :map])
map = Keyword.get(options, :map, "sample.json")
IO.puts("Running players for map #{map}...")

games =
  Livegames.list_empty()
  |> Enum.filter( &(Enum.empty?(&1.extensions)) )
  |> Enum.filter( &(&1.map_name == map) )
  |> Enum.shuffle

if Enum.empty?(games) do
    IO.puts("No empty games for #{map}")
    System.halt
end
game = games |> hd
if game == nil do
    IO.puts("No empty games for #{map}")
end
IO.puts("Found a game using #{map} with #{game.seats} seats.")
IO.puts("About to play on port #{game.port}")

strategies = [
    Compete.grab_mines_then_roll_voyager_vs_build(),
    BuildFromMinesOrRandom,
    VoyagerOrRandom,
    GrabMinesThenVoyagerThenRandom,
    Compete.grab_mines_then_roll_voyager_vs_build(),
    Compete.grab_mines_then_roll_voyager_vs_build()
]

result =
  Range.new(0, game.seats - 1)
  |> Enum.zip(Stream.cycle(strategies))
  |> Enum.map(fn {n, strategy} ->
    Task.async(fn ->
      Process.flag(:trap_exit, true)

      Punting.Player.start_link(
        Punting.OnlineMode,
        mode_arg: game.port,
        scores:   self(),
        strategy: strategy
      )
      IO.puts("Started player #{n}.")
  
      receive do
        {:result, _moves, _id, _scores, _state} = result -> result
        _ -> nil
      end
    end)
  end)
|> Enum.map(fn t -> Task.await(t, :infinity) end)
|> Enum.filter(fn result -> not is_nil(result) end)

case hd(result) do
    {:result, _, _, scores, _} -> IO.inspect(scores)
    x ->
        IO.puts("what's this result?\n#{inspect(x)}")
end

