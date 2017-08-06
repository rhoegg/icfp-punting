alias Punting.Strategy.{BuildFromMines,Voyager,RollDice,RandomChoice,Composite}
alias Punting.Strategy.GrabMinesWithLeastAvailableSpokes, as: MineHoarder
alias Punting.Strategy.GrabMinesWithMostAvailableSpokes, as: MineCollector
alias Punting.Strategy.BuildToMinesWeDontOwn, as: MineSeeker

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

defmodule GrabMinesThenVoyager do
    def move(game) do
        Composite.move(game, [
            Compete.Experiment.first_n_turns(MineCollector, 5),
            Voyager,
            RandomChoice
        ])
    end
end

defmodule HoardThenVoyager do
    def move(game) do
        Composite.move(game, [
            MineHoarder,
            Voyager,
            RandomChoice
        ])
    end
end

defmodule SeekerThenBuildThenRandom do
  def move(game) do
    Composite.move(game, [
          MineSeeker,
          BuildFromMines,
          RandomChoice
        ])
  end
end

defmodule Compete.Experiment do
    def grab_mines_then_roll_voyager_vs_build() do
        grab_turns = :rand.uniform(16)
        target = :rand.uniform(6)
        {
            "Gt#{grab_turns} d#{target}/6(VB)",
            fn :move -> fn game ->
                Composite.move(game, [
                    first_n_turns(MineHoarder, grab_turns),
                    roll_d6(target, Voyager, BuildFromMines),
                    RandomChoice
                ])
            end end
        }
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

    def pretty_scores(scores) do
        scores
        |> Enum.map(fn %{"punter" => p, "score" => s} -> "#{p}: #{s}" end)
        |> Enum.join("\n")
    end

    defp resolve(strategy) when is_function(strategy) do
        strategy.(:move)
    end

    defp resolve(strategy) when is_atom(strategy) do
        fn game -> strategy.move(game) end
    end

    def base_strategies() do
        %{
            "H V" => HoardThenVoyager,
            "B" => BuildFromMinesOrRandom,
            "V" => VoyagerOrRandom,
            "Ct5 V" => GrabMinesThenVoyager,
            "S B" => SeekerThenBuildThenRandom,
        }
    end

    def spice_up(strategies, 0), do: strategies
    def spice_up(strategies, n) do
        [
            grab_mines_then_roll_voyager_vs_build()
            | spice_up(strategies, n - 1)
        ]
    end

    def compete(game, strategies) do
      Range.new(0, game.seats - 1)
      |> Enum.zip(Stream.cycle(strategies))
      |> Enum.map(fn {n, {name, strategy}} ->
        Task.async(fn ->
          Process.flag(:trap_exit, true)

          Punting.Player.start_link(
            Punting.OnlineMode,
            mode_arg: game.port,
            scores:   self(),
            strategy: strategy
          )
          IO.puts("Player #{n}: #{name}")
      
          receive do
            {:result, _moves, _id, _scores, _state} = result -> result
            _ -> nil
          end
        end)
      end)
        |> Enum.map(fn t -> Task.await(t, :infinity) end)
        |> Enum.filter(fn result -> not is_nil(result) end)
    end

    def run_one_empty(map) do
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

        strategies = base_strategies()
        |> Map.to_list
        |> spice_up(2)
        |> Enum.shuffle

        IO.puts("Playing #{game.map_name}:#{game.port} with #{game.seats} players.")
        result = compete(game, strategies)

        case hd(result) do
            {:result, _, _, scores, _} -> IO.puts(pretty_scores(scores))
            x ->
                IO.puts("what's this result?\n#{inspect(x)}")
        end
    end

    def run_generation(_, 0), do: nil
    def run_generation(strategies, iterations) do
        candidates = Livegames.list_empty()
        |> Enum.filter( &(Enum.empty?(&1.extensions)) )
        |> Enum.shuffle()
        
        if Enum.empty?(candidates) do
            IO.puts("no empty games!")
            run_generation(strategies, iterations)
        else 
          game = hd(candidates)
          IO.puts("#{game.map_name}:#{game.port}/#{game.seats}")
          scores = game
            |> compete(strategies)
            |> save_scores
          if scores do          
              [
                %{
                    scores: scores,
                    map: game.map_name,
                    port: game.port
                }
                | run_generation(strategies, iterations - 1)
              ]
          else
            IO.puts("Trying generation again")
            run_generation(strategies, iterations)
          end
        end
    end

    defp save_scores([{:result, _, _, scores, _} | _]) do
        scores
        |> Enum.map(fn %{"punter" => p, "score" => s} -> {p, s} end)
        |> Map.new
    end
    defp save_scores(result) do
        IO.puts("Problem handling game result: #{inspect(result)}")
        nil
    end
end
