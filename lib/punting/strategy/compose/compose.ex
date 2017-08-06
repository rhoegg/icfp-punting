defmodule Punting.Strategy.Compose do
  alias Punting.Strategy.RollDice
    
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

    def roll_d6(target, win_strategy, lose_strategy) do
        RollDice.strategy(target, 6, win_strategy, lose_strategy)
    end
end
