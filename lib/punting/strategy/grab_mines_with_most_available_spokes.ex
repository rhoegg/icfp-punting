defmodule Punting.Strategy.GrabMinesWithMostAvailableSpokes do
  def move(initial_game) do
    my_id = initial_game["id"]
    mines_to_me = Punting.DataStructure.MinesToMe.find(
      initial_game["mines"],
      initial_game[my_id]
    )
    updated_game = MineRoutes.start(
      mines_to_me,
      initial_game["available"],
      initial_game["total_turns"]
    )
    get_step(updated_game, mines_to_me)
  end

  def get_step(game_state, mines_to_me) do
    valid_paths = game_state["all_trees"]
    |> Enum.filter( &(Enum.member?(mines_to_me, hd(&1))) )
     
    [source, target | _rest] = valid_paths
    |> Enum.group_by(&hd/1)
    |> Map.values
    |> Enum.sort_by(&(length(&1)))
    |> Enum.reverse
    |> List.flatten

    {source, target}
  end
end
