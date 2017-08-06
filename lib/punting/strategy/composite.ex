defmodule Punting.Strategy.Composite do
    def move(game, rules) do
        maybe_move(game, List.wrap(rules))
    end

    def maybe_move(game, []), do: Punting.Strategy.AlwaysPass.move(game)
    def maybe_move(game, [head | tail]) do
        if should_use?(game, head) do
            resolve(head).(game)
        end
        || maybe_move(game, tail)
    end

    defp resolve(strategy) do
        case strategy do
          module when is_atom(module) -> fn game -> module.move(game) end
          f      when is_function(f)  -> f.(:move)
        end
    end

    def should_use?(game, rule) do
        cond do
          is_function(rule) ->
            true
          Keyword.has_key?(rule.__info__(:functions), :use?) ->
            rule.use?(game)
          true ->
            true
        end
    end
end