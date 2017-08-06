defmodule Punting.Strategy.Compose.Examples.BuildFromMinesOrRandom do
  alias Punting.Strategy.Composite
  alias Punting.Strategy.{BuildFromMines, RandomChoice}

    def move(game) do
        Composite.move(game, [
            BuildFromMines,
            RandomChoice
        ])
    end
end

defmodule Punting.Strategy.Compose.Examples.VoyagerOrRandom do
  alias Punting.Strategy.Composite
  alias Punting.Strategy.{Voyager, RandomChoice}
    def move(game) do
        Composite.move(game, [
            Voyager,
            RandomChoice
        ])
    end
end

defmodule Punting.Strategy.Compose.Examples.GrabMinesThenVoyager do
  alias Punting.Strategy.Composite
  alias Punting.Strategy.GrabMinesWithMostAvailableSpokes, as: MineCollector
  alias Punting.Strategy.{Compose, Voyager, RandomChoice}
    def move(game) do
        Composite.move(game, [
            Compose.first_n_turns(MineCollector, 5),
            Voyager,
            RandomChoice
        ])
    end
end

defmodule Punting.Strategy.Compose.Examples.HoardThenVoyager do
  alias Punting.Strategy.Composite
  alias Punting.Strategy.GrabMinesWithLeastAvailableSpokes, as: MineHoarder
  alias Punting.Strategy.{Voyager, RandomChoice}
    def move(game) do
        Composite.move(game, [
            MineHoarder,
            Voyager,
            RandomChoice
        ])
    end
end

defmodule Punting.Strategy.Compose.Examples.SeekerThenBuildThenRandom do
  alias Punting.Strategy.Composite
  alias Punting.Strategy.BuildToMinesWeDontOwn, as: MineSeeker
  alias Punting.Strategy.{BuildFromMines, RandomChoice}
  def move(game) do
    Composite.move(game, [
          MineSeeker,
          BuildFromMines,
          RandomChoice
        ])
  end
end

defmodule Punting.Strategy.Compose.Examples.SpiderMan do
  alias Punting.Strategy.Composite
  alias Punting.Strategy.BuildToMinesWeDontOwn, as: MineSeeker
  alias Punting.Strategy.{Voyager, BuildFromMines, RandomChoice}
  def move(game) do
    Composite.move(game, [
          MineSeeker,
          BuildFromMines,
          Voyager,
          RandomChoice
        ])
  end
end
