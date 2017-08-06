 defmodule Punting.Strategy.Compose.Examples do
  alias Punting.Strategy.Composite
  alias Punting.Strategy.Compose
  alias Punting.Strategy.GrabMinesWithLeastAvailableSpokes, as: MineHoarder
  alias Punting.Strategy.{RandomChoice, Voyager, BuildFromMines}

    def grab_mines_then_roll_voyager_vs_build() do
        grab_turns = :rand.uniform(16)
        target = :rand.uniform(6)
        {
            "Gt#{grab_turns} d#{target}/6(VB)",
            fn :move -> fn game ->
                Composite.move(game, [
                    Compose.first_n_turns(MineHoarder, grab_turns),
                    Compose.roll_d6(target, Voyager, BuildFromMines),
                    RandomChoice
                ])
            end end
        }
    end
    
end
