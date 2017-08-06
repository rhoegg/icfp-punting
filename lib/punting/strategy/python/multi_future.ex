defmodule Punting.Strategy.Isaac.MultiFutures do
    
    def futures(game) do
        PythonPhone.subscribe(self())
	#KWARGS TO CONSIDER FOR BETTING:
	# max_pts_to_consider:  Number of potential end spots to consider
	#                       for each mine.  Affects run time, defaults to 10
        #
	# min_degree         :  Minimum number of neighbors of each mine
        #                       or point to be considered.  Defaults to 3.  For
        #                       small maps, this could be bad.
	#
        # bridge_dist_threshold: Maximum distance cutting a segement out of the
	#                        shortest path is allowed to change the path
	#                        before being called a "bridge"  default=5
	#                        Increase to allow for more choke-points.
        #
	# bridge_num_threshold:  Minimum number of bridges that are allowed
        #                        to exceed bridge_dist_threshold. default=2
       	#
	# bridge_cut_threshold:  Remove potential future from consideration
        #                        if cutting this many segments can disconnect
        #                        mine and target.  defaults to 2

        PythonPhone.talk(%{
            strategy: __MODULE__ |> Module.split |> List.last,
            tag: __MODULE__,
            function: "bet",
            kwargs: %{max_pts_to_consider: 9},
            game: game,
            state: %{},
            comment: "Hello Isaac"
        })

        tag = Atom.to_string(__MODULE__)
        receive do
            {:reply, %{"tag" => tag} = msg} -> msg
        end
    end

    def move(game) do
        PythonPhone.subscribe(self())
        PythonPhone.talk(%{
            strategy: __MODULE__ |> Module.split |> List.last,
            tag: __MODULE__,
            function: "move",
            kwargs: %{},
            game: game,
            state: %{},
            comment: "Move Isaac"
        })

        tag = Atom.to_string(__MODULE__)
        receive do
            {:reply, %{"tag" => tag} = msg} -> msg
        end
    end
end