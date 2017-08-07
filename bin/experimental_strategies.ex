alias Punting.Strategy.Compose.Examples.{VoyagerOrRandom,SpiderMan}
alias Punting.Strategy.Compose
alias Punting.Strategy.{BackToTheFuture,Composite,CovetMines,MineHoarder,Voyager,RandomChoice}

defmodule Covet do
  def move(game) do
    Composite.move(game, [
        CovetMines,
        RandomChoice
    ])
  end
end

defmodule HoardThenSpiderman do
  def move(game) do
    mines = Map.get(game, "mines") |> Enum.count
    Composite.move(game, [
        Compose.first_n_turns(MineHoarder, mines * 2),
        SpiderMan,
        RandomChoice
    ])
  end
end

defmodule HoardThenVoyager do
  def move(game) do
    mines = Map.get(game, "mines") |> Enum.count
    Composite.move(game, [
        Compose.first_n_turns(MineHoarder, mines * 2),
        Voyager,
        RandomChoice
    ])
  end
end

defmodule Compete.Experiment do

    def pretty_scores(scores) do
        scores
        |> Enum.map(fn {p, {n, s}} -> "#{p}:   #{s} = #{n}" end)
        |> Enum.join("\n")
    end

    def base_strategies() do
        %{
            "S" => SpiderMan,
            "C" => Covet,
            "B" => BackToTheFuture,
            "V" => HoardThenVoyager,
            "W" => HoardThenSpiderman
        }
    end

    def spice_up(0), do: []
    def spice_up(n) do
        [
            Compose.Examples.grab_mines_then_roll_voyager_vs_spiderman()
            | spice_up(n - 1)
        ]
    end

    def compete(game, strategies) do
      players = game.seats - game.players
      |> (fn x -> if x <= 4, do: x, else: 4 end).()

      Range.new(0, players)
      |> Enum.zip(Stream.cycle(IO.inspect(strategies)))
      |> Enum.map(fn {n, {name, strategy}} ->
        Task.async(fn ->
          Process.flag(:trap_exit, true)

          Punting.Player.start_link(
            mode:     Punting.OnlineMode,
            mode_arg: game.port,
            scores:   self(),
            strategy: strategy
          )
          IO.puts("Started player #{n} with strategy #{name}")
      
          receive do
            {:result, moves, id, scores, _state} -> 
              {:result, moves, id, name, scores}
            _ ->
              IO.puts("Died: #{name}")
              {:dead, nil, n, name, nil}
          end
        end)
      end)
      |> Enum.map(fn t -> Task.await(t, :infinity) end)
      |> Enum.filter(fn result -> not is_nil(result) end)
    end

    def run_one_empty(map) do
        games = get_game_candidates(map, 2)

        if Enum.empty?(games) do
            IO.puts("No empty games for #{map}")
            System.halt
        end
        game = games |> hd
        if game == nil do
            IO.puts("No empty games for #{map}")
        end

        strategies = 
          base_strategies() 
          |> Map.to_list 
          |> Enum.concat(spice_up(2))
          |> Enum.shuffle

        IO.puts("Playing #{game.map_name}:#{game.port} with #{game.seats} players.")
        result = compete(game, strategies)
        |> save_scores

        result
        |> pretty_scores
        |> IO.puts
    end

    def run_generation(_, _map, 0), do: nil
    def run_generation(strategies, map, iterations) do
        IO.puts("Running iteration #{iterations} for #{map || 'any map'}")
        candidates = get_game_candidates(map, 2)
        if Enum.empty?(candidates) do
            IO.puts("no games with players or less!")
            run_generation(strategies, map, iterations)
        else 
          game = candidates
          |> hd
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
                | run_generation(strategies, map, iterations - 1)
              ]
          else
            IO.puts("Trying generation again")
            run_generation(strategies, map, iterations)
          end
        end
    end

    defp get_game_candidates(max_players) do
      Livegames.list()
        |> Enum.filter( &(&1.seats > 2 && &1.seats < 9) )
        |> Enum.filter( &(Enum.empty?(&1.extensions)) )
#        |> Enum.filter( &(&1.players <= max_players) )
        |> Enum.shuffle()
    end
    defp get_game_candidates(map, max_players) do
      games = get_game_candidates(max_players)
      if (map) do
        games
        |> Enum.filter( &(&1.map_name == map) )
      else
        games
      end
    end

    defp save_scores([]), do: []
    defp save_scores([{:result, _, _id, _name, scores} | others]) do
        other_ids = others
        |> Enum.map(fn other -> 
          case other do
            {:result, _, id, name, _} -> {id, name}
            {:dead, _, id, name, _} -> {id, name}
          end
        end)
        |> Map.new
        scores
        |> Enum.map(fn %{"punter" => p, "score" => s} -> {p, s} end)
        |> Enum.map(fn {id, score} -> 
            {id, {Map.get(other_ids, id), score}}
          end)
        |> Map.new
    end
    defp save_scores([dead | others]) do
      save_scores(others ++ [dead])
    end

    def pretty_result(result) do
      inspect(result)
    end
end
