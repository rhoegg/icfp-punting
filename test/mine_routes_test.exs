defmodule MineRoutesTest do
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
    # game = DataStructure.process(setup_message) |> IO.inspect

    game_data = %{
      0 => %{0 => [7, 1], 1 => [2, 7, 3, 0], 2 => [1, 3],
    3 => [5, 1, 2, 4], 4 => [5, 3], 5 => [7, 3, 4, 6], 6 => [7, 5],
    7 => [0, 1, 5, 6]},
    "all_trees" => [[6, 5], [7, 6, 5], [1, 7, 6, 5], [1, 0, 7, 6, 5],
   [0, 7, 6, 5], [3, 4, 5], [2, 3, 4, 5], [1, 2, 3, 4, 5], [1, 3, 4, 5], [4, 5],
   [4, 3, 5], [2, 3, 5], [1, 2, 3, 5], [1, 3, 5], [3, 5], [6, 7, 5], [7, 5],
   [1, 7, 5], [1, 0, 7, 5], [0, 7, 5], [0, 1], [5, 6, 7, 0, 1], [6, 7, 0, 1],
   [5, 7, 0, 1], [7, 0, 1], [4, 3, 1], [5, 4, 3, 1], [2, 3, 1], [3, 1],
   [5, 3, 1], [5, 6, 7, 1], [6, 7, 1], [5, 7, 1], [7, 1], [0, 7, 1],
   [4, 3, 2, 1], [5, 4, 3, 2, 1], [3, 2, 1], [5, 3, 2, 1], [2, 1]],
    "available" => %{0 => [7, 1], 1 => [2, 7, 3, 0], 2 => [1, 3],
    3 => [5, 1, 2, 4], 4 => [5, 3], 5 => [7, 3, 4, 6], 6 => [7, 5],
    7 => [0, 1, 5, 6]}, "id" => 0,
    "initial" => %{0 => [7, 1], 1 => [2, 7, 3, 0], 2 => [1, 3], 3 => [5, 1, 2, 4],
    4 => [5, 3], 5 => [7, 3, 4, 6], 6 => [7, 5], 7 => [0, 1, 5, 6]},
    "mine_route_map" => %{3 => [[1, 3, 5], [1, 7, 5], [5, 3, 1], 5, 7, 1],
    4 => [[1, 7, 6, 5], [1, 3, 4, 5], [1, 2, 3, 5], [1, 0, 7, 5], [5, 7, 0, 1],
     [5, 4, 3, 1], [5, 6, 7, 1], 5, 3, 2, 1],
    5 => [[1, 0, 7, 6, 5], [1, 2, 3, 4, 5], [5, 6, 7, 0, 1], 5, 4, 3, 2, 1]},
    "mines" => [1, 5], "number_of_punters" => 2,
    "other_routes" => [[1, 2], [1, 2, 3], [1, 2, 3, 4], [1, 7, 0], [1, 7],
   [1, 7, 6], [1, 3], [1, 3, 2], [1, 3, 4], [1, 0, 7], [1, 0, 7, 6], [1, 0],
   [5, 7, 0], [5, 7], [5, 7, 6], [5, 3], [5, 3, 2], [5, 3, 4], [5, 4],
   [5, 4, 3, 2], [5, 4, 3], [5, 6, 7, 0], [5, 6, 7], [5, 6]],
   "total_rivers" => 12, "total_turns" => 6.0,
    "trees_with_mine_bookends" => [[5, 3, 2, 1], [5, 4, 3, 2, 1], [5, 7, 1],
   [5, 6, 7, 1], [5, 3, 1], [5, 4, 3, 1], [5, 7, 0, 1], [5, 6, 7, 0, 1],
   [1, 0, 7, 5], [1, 7, 5], [1, 3, 5], [1, 2, 3, 5], [1, 3, 4, 5],
   [1, 2, 3, 4, 5], [1, 0, 7, 6, 5], [1, 7, 6, 5]],
   "turns_taken" => 0}


    blah = MineRoutes.our_info(game_data)
    # moves = [%{"claim"=>%{"punter"=>0,"source"=>0,"target"=>1}},%{"claim"=>%{"punter"=>1,"source"=>1,"target"=>2}}]
    # moves_message = {:move, moves, initial_state}
    # result = DataStructure.process(moves_message)

    # assert 2 == Map.get(result, "turns_taken")
    # assert punter_moves(result, 0) == %{0 => [1], 1 => [0]}
    # assert punter_moves(result, 1) == %{1 => [2], 2 => [1]}

    # available_moves = Map.get(result, "available")
    # refute has_move?(available_moves, 0, 1)
    # refute has_move?(available_moves, 2, 1)
  end
end
