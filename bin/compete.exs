# game =
#   Livegames.list_empty()
#   |> Enum.filter( &(Enum.empty?(&1.extensions)) )
#   |> Enum.filter( &(&1.map_name == "lambda.json") )
# |> hd
# IO.puts("Found a game with #{game.seats} seats.")
# result =
#   Range.new(0, game.seats - 1)
#   |> Enum.map(fn _n ->
#   Task.async(fn ->
#     Process.flag(:trap_exit, true)

#     Punting.Player.start_link(
#       Punting.OnlineMode,
#       mode_arg: game.port,
#       scores:   self(),
#       strategy: Punting.Strategy.AlwaysPass
#     )

#     receive do
#       {:result, _moves, _id, _scores, _state} = result -> result
#       _ -> nil
#     end
#   end)
# end)
# |> Enum.map(fn t -> Task.await(t, :infinity) end)
# |> Enum.filter(fn result -> not is_nil(result) end)

# IO.inspect(result)

System.argv
|> IO.inspect
