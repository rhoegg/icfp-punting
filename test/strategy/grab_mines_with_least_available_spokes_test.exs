defmodule Punting.Strategy.GrabMinesWithLeastAvailableSpokesTest do
  use ExUnit.Case, async: true

  test "finds_a_path" do
    game_map =
      %{"sites"=>[%{"id"=>4},%{"id"=>1},%{"id"=>3},%{"id"=>6},%{"id"=>5},%{"id"=>0},%{"id"=>7},%{"id"=>2}],
        "rivers"=>[%{"source"=>3,"target"=>4},%{"source"=>0,"target"=>1},%{"source"=>2,"target"=>3},
                   %{"source"=>1,"target"=>3},%{"source"=>5,"target"=>6},%{"source"=>4,"target"=>5},
                   %{"source"=>3,"target"=>5},%{"source"=>6,"target"=>7},%{"source"=>5,"target"=>7},
                   %{"source"=>1,"target"=>7},%{"source"=>0,"target"=>7},%{"source"=>1,"target"=>2},%{"source"=>5,"target"=>2}],
        "mines"=>[1,5]}

    setup_message = {:setup, 0, 2, game_map}
    initial_state = DataStructure.process(setup_message)
    {source, destination} = move(initial_state)
    assert {1, 3} == {source, destination}

    moves = [
      %{"claim"=>%{"punter"=>0,"source"=>1,"target"=>3}},
      %{"claim"=>%{"punter"=>1,"source"=>1,"target"=>7}}
    ]
    new_state = DataStructure.process({:move, moves, initial_state})
    {new_source, new_destination} = move(new_state)

    final_moves = [
      %{"claim"=>%{"punter"=>0,"source"=>1,"target"=>7}},
      %{"claim"=>%{"punter"=>1,"source"=>1,"target"=>3}},
      %{"claim"=>%{"punter"=>0,"source"=>1,"target"=>2}},
      %{"claim"=>%{"punter"=>1,"source"=>6,"target"=>5}}
    ]
    final_state = DataStructure.process({:move, final_moves, new_state})
    {final_source, final_destination} = move(final_state)
    assert {0, 1} == {final_source, final_destination}
  end

  defp move(game) do
    Punting.Strategy.GrabMinesWithLeastAvailableSpokes.move(game)
    |> normalize
  end

  defp normalize(nil), do: nil
  defp normalize({x, y} = river) when x > y, do: {y, x}
  defp normalize({_, _} = river), do: river
end
