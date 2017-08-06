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
            Combine.first_n_turns(MineCollector, 5),
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
