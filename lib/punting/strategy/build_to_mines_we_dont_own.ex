defmodule Punting.Strategy.BuildToMinesWeDontOwn do
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

    mines_i_do_not_own = initial_game["mines"]
    |> Enum.filter(&(Enum.member?(mines_to_me, &1)))

    get_step(initial_game, updated_game, mines_i_do_not_own, mines_to_me)
  end

  def get_step(initial, game_state, [], mines_to_me) do
    nil
  end
  def get_step(initial, game_state, mines_i_do_not_own, mines_to_me) do
    candidates = game_state["trees_with_mine_bookends"]
    |> Enum.filter(&(own_end_mine?(&1, mines_i_do_not_own)))
    |> Enum.filter(&( length(&1) <= available_steps(initial) ))
    |> Enum.sort(&( length(&1) <= length(&2)))
    make_selection(candidates)
  end

  def own_end_mine?(mine_list, mines_i_do_not_own) do
    last = mine_list
    |> Enum.reverse
    |> hd

    Enum.member?(mines_i_do_not_own, last)
  end

  def available_steps(initial) do
    (initial["total_turns"] - initial["turns_taken"])
    |> Float.floor
    |> Float.round
  end

  def make_selection([]) do
    nil
  end
  def make_selection([list | _rest]) do
    [source, destination | _rest] = list
    {source, destination}
  end
end
