 defmodule Punting.Strategy.Compose.Examples do
  alias Punting.Strategy.Composite
  alias Punting.Strategy.Compose
  alias Punting.Strategy.Compose.Examples.SpiderMan
  alias Punting.Strategy.{RandomChoice, Voyager, MineHoarder}

    def grab_mines_then_roll_voyager_vs_spiderman() do
        grab_turns = :rand.uniform(16)
        target = :rand.uniform(6)
        {
            "Ht#{grab_turns} #{target}d6VS",
            fn :move -> fn game ->
                Composite.move(game, [
                    Compose.first_n_turns(MineHoarder, grab_turns),
                    Compose.roll_d6(target, Voyager, SpiderMan),
                    RandomChoice
                ])
            end end
        }
    end
    
end
