defmodule Punting.Strategy.Composite do
    def move(game, rules) do
        match(game, List.wrap(rules)).move(game)
    end

    def match(_game, []), do: Punting.Strategy.AlwaysPass
    def match(game, [head | tail]) do
        if should_use?(game, head) do
            head
        else
            match(game, tail)
        end
    end

    def should_use?(game, rule) do
        if Keyword.has_key?(rule.__info__(:functions), :use?) do
            rule.use?(game)
        else
            true
        end
    end
end