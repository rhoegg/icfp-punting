defmodule Punting.Strategy.RollDice do
    def move(game, target, sides, strategy1, strategy2) do
        s = if roll(target, sides), do: strategy1, else: strategy2
        s.move(game)
    end

    def roll(target, sides) do
        result = maybe_cheat() 
        || random_roll(sides)
        result < target
    end

    defp random_roll(sides) do
        Range.new(1, sides)
        |> Enum.random
    end

    defp maybe_cheat() do
        if result = Application.get_env(:punting, :next_dice_roll) do
            Application.delete_env(:punting, :next_dice_roll)
        end
        result
    end
end