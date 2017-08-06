defmodule Punting.Strategy.Composite do
    def move(game, rules) do
        maybe_move(game, List.wrap(rules))
    end

    def maybe_move(game, []), do: Punting.Strategy.AlwaysPass.move(game)
    def maybe_move(game, [head | tail]) do
        if(should_use?(game, head), do: head.move(game))
            || maybe_move(game, tail)
    end

    def should_use?(game, rule) do
        if Keyword.has_key?(rule.__info__(:functions), :use?) do
            rule.use?(game)
        else
            true
        end
    end
end