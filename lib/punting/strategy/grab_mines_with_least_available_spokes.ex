defmodule Punting.Strategy.GrabMinesWithLeastAvailableSpokes do
  def move(game) do
    my_id = game["id"]
    mines_to_me = Punting.DataStructure.MinesToMe.find(
      game["mines"],
      game[my_id]
    )
    updated_game = MineRoutes.start(
      mines_to_me,
      game["available"],
      game["total_turns"]
    )
    updated_game["other_routes"]
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
