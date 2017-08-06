defmodule Punting.DataStructure.ScoreKeeperTest do
  use ExUnit.Case
  alias Punting.DataStructure.ScoreKeeper

  setup _context do
    {:ok, pid} = Punting.DataStructure.ScoreKeeper.start()
    {:ok, server: pid}
  end

  test "saves a score by id", %{server: server} do
    ScoreKeeper.add_score(server, [1,2,3], 3)
    assert ScoreKeeper.get_score(server, "1-3") == 9.0
  end

  test "saves only the lowest score", %{server: server} do
    ScoreKeeper.add_score(server, [1,2,3], 3)
    assert ScoreKeeper.get_score(server, "1-3") == 9.0

    ScoreKeeper.add_score(server, [1, 2, 5, 7, 3], 3)
    assert ScoreKeeper.get_score(server, "1-3") == 9.0
  end

  test "returns all scores", %{server: server} do
    ScoreKeeper.add_score(server, [1,2,3], 3)
    ScoreKeeper.add_score(server, [1, 5, 7, 8], 8)

    assert ScoreKeeper.scores(server) == %{"1-3" => 9.0, "1-8" => 16.0}
  end

end
