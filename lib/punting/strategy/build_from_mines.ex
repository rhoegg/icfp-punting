defmodule Punting.Strategy.BuildFromMines do
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
    get_step(initial_game, updated_game, mines_to_me)
  end

  def get_step(initial, game_state, mines_to_me) do
    steps = game_state["trees_with_mine_bookends"]
    |> Enum.filter(&( length(&1) <= available_steps(initial) ))
    |> Enum.sort(&( length(&1) <= length(&2)))

    if steps = [] do
      nil
    else
      steps
      |> hd      # just take first for now. Add evaluator later.
      |> next_step(initial)
    end
  end

  def available_steps(initial) do
    (initial["total_turns"] - initial["turns_taken"])
    |> Float.floor
    |> Float.round
  end

  defp next_step([source, destination | _rest], _initial) do
    {source, destination}
  end
  defp next_step([], initial) do
    nil
  end
end
