defmodule Punting.Strategy.GrabMinesWithMostAvailableSpokesTest do
  use ExUnit.Case, async: true

  test "finds_a_path" do
    game_map =
      %{"sites"=>[%{"id"=>4},%{"id"=>1},%{"id"=>3},%{"id"=>6},%{"id"=>5},%{"id"=>0},%{"id"=>7},%{"id"=>2}],
        "rivers"=>[%{"source"=>3,"target"=>4},%{"source"=>0,"target"=>1},%{"source"=>2,"target"=>3},
                   %{"source"=>1,"target"=>3},%{"source"=>5,"target"=>6},%{"source"=>4,"target"=>5},
                   %{"source"=>3,"target"=>5},%{"source"=>6,"target"=>7},%{"source"=>5,"target"=>7},
                   %{"source"=>1,"target"=>7},%{"source"=>0,"target"=>7},%{"source"=>1,"target"=>2}],
        "mines"=>[1,5]}

    setup_message = {:setup, 0, 2, game_map}
    initial_state = DataStructure.process(setup_message)
    assert {5, 6} == Punting.Strategy.GrabMinesWithMostAvailableSpokes.move(initial_state)
    moves = [%{"claim"=>%{"punter"=>0,"source"=>5,"target"=>6}},%{"claim"=>%{"punter"=>1,"source"=>5,"target"=>3}}]
    new_state = DataStructure.process({:move, moves, initial_state})
    assert {1, 2} == Punting.Strategy.GrabMinesWithMostAvailableSpokes.move(new_state)
  end
end
