defmodule Punting.Strategy.GrabMinesWithLeastAvailableSpokes do
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
    updated_game["all_trees"]
    |> Enum.filter( &(Enum.member?(mines_to_me, hd(&1))) )
    |> get_step
  end

  def get_step([]) do
    nil
  end
  def get_step(valid_paths) do
    [source, target | _rest] = valid_paths
    |> Enum.group_by(&hd/1)
    |> Map.values
    |> Enum.sort_by(&(length(&1)))
    |> List.flatten

    {source, target}
  end
end
