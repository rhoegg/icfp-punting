defmodule GraphTest do
  use ExUnit.Case
  test "process setup" do
    game_map =
      %{"sites"=>[%{"id"=>4},%{"id"=>1},%{"id"=>3},%{"id"=>6},%{"id"=>5},%{"id"=>0},%{"id"=>7},%{"id"=>2}],
        "rivers"=>[%{"source"=>3,"target"=>4},%{"source"=>0,"target"=>1},%{"source"=>2,"target"=>3},
                   %{"source"=>1,"target"=>3},%{"source"=>5,"target"=>6},%{"source"=>4,"target"=>5},
                   %{"source"=>3,"target"=>5},%{"source"=>6,"target"=>7},%{"source"=>5,"target"=>7},
                   %{"source"=>1,"target"=>7},%{"source"=>0,"target"=>7},%{"source"=>1,"target"=>2}],
        "mines"=>[1,5]}

    setup_message = {:setup, 0, 2, game_map}
    initial_state = Graph.process(setup_message)


    moves = [%{"claim"=>%{"punter"=>0,"source"=>0,"target"=>1}},%{"claim"=>%{"punter"=>1,"source"=>1,"target"=>2}}]
    moves_message = {:move, moves, initial_state}
    result = Graph.process(moves_message)

    assert 2 == Map.get(result, "turns_taken")
    assert punter_moves(result, 0) == %{0 => [1], 1 => [0]}
    assert punter_moves(result, 1) == %{1 => [2], 2 => [1]}

    available_moves = Map.get(result, "available")
    refute has_move?(available_moves, 0, 1)
    refute has_move?(available_moves, 2, 1)
  end

  defp has_move?(available_moves, site, move) do
    Enum.member?(Map.get(available_moves, site), move)
  end

  defp punter_moves(result, id) do
    Map.get(result, id)
  end
end
