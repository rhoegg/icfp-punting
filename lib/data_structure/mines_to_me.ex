defmodule Punting.DataStructure.MinesToMe do
  def find(canonical_mines, my_moves) do
    my_moves
    |> Map.take(canonical_mines)
    |> Map.values
    |> List.flatten
    |> find(my_moves, canonical_mines)
  end
  def find([], _my_moves, acc) do
    acc
  end
  def find([hd | tail], my_moves, acc) do
    {add_to_acc, new_my_moves} = Map.pop(my_moves, hd)
    new_acc = if add_to_acc do
      Enum.uniq([hd] ++ add_to_acc ++ acc)
    else
      acc
    end
    find(tail, new_my_moves, new_acc)
  end
end
