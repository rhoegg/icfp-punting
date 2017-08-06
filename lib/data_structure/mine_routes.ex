defmodule MineRoutes do

    alias Punting.DataStructure.ScoreKeeper

    def start(game) do
        start(game["mines"], game["available"], max_length(game))

    end
    def start(game, max_length) do
        start(game["mines"], game["available"], max_length)
    end
    def start(mines, edge_map, max_length) do
        all_trees = build_trees(mines, edge_map, max_length)
        mine_to_mine_routes = m2m_routes(all_trees, mines)
        other_routes = other_routes(all_trees, mines)
        mine_route_map = make_route_length_map(mine_to_mine_routes)
        %{
            "trees_with_mine_bookends" => mine_to_mine_routes,
            "mine_route_map" => mine_route_map,
            "other_routes"  => other_routes
        }
    end
    def max_length(game) do
        [ (game["total_rivers"] - game["turns_taken"]) / game["number_of_punters"] ,7] 
        |> Enum.min
    end

    # returns a map of all paths from given mines on
    # the given edge map
    # start calls this will all mines. On larger maps
    # you may want to use with fewer mines to ensure that
    # processing complete quickly
    def build_trees(mines, edge_map, max_length) do
        build_trees(mines, edge_map, max_length, false)
    end
    def build_trees(mines, edge_map, max_length, score_keeper) do
        acc = []
        lists = mines
        |> Enum.map(fn(mine) -> build_tree(acc, mine, edge_map, mines, max_length, score_keeper) end)
        |> flatten_me([])
        |> Enum.uniq
    end

    # this method return all trees to all mines, you must specify
    # the max length. Calls to start will default to a length of 6
    def get_all_trees(game, max_length) do
        build_trees(game["mines"], game["available"], max_length)
    end
    def get_all_trees(game, max_length, score_keeper) do

        build_trees(game["mines"], game["available"], max_length, score_keeper)
    end

    # send in a list of trees and the mines
    def m2m_routes(trees, mines) do
        trees
            |> Enum.reduce([], fn(item, a) -> find_mine_routes_to_specified_sites(item, mines, a) end)
    end

    # send in a list of trees and the mines
    # routes are returned with the mine in the front of the list
    def other_routes(trees, mines) do
        trees
            |> Enum.reduce([], fn(item, a) -> find_mines_routes_not_ending_at_specific_sites(item, mines, a) end)
            |> Enum.map(fn(path) -> Enum.reverse(path) end)
    end

    # send in a list of trees and the mines
    # routes are returned with the mine in the front of the list
    def other_routes_mine_last(trees, mines) do
        trees
            |> Enum.reduce([], fn(item, a) -> find_mines_routes_not_ending_at_specific_sites(item, mines, a) end)
    end


    def our_info(game) do
        existing_map = our_tree(game)
        %{
            "our_tree" => existing_map,
            "aliases" => mine_aliases(existing_map, game["mines"])
        }
    end

    # returns a list of maps that shows paths we have from mines
    def our_tree(game) do
        id = game["id"]
        case Enum.count(game[id]) == %{} do
            true -> nil
            false -> build_trees(game["mines"], game[id], max_length(game), true)
        end
        # |> Enum.map(fn(path) -> IO.inspect "here we go"; IO.inspect path; List.reverse(path) end)
        # we want to track our maps to mines, when a sub map connects to another
        # we want to stop pursuing connecting those 2 mines
        # use our map from game data and then build all the trees.
        # use endpoints of our existing mine paths as aliases for calculating our plans
        # save off non mine paths to other data structure
    end

    def build_alias_map(mines, aliases) do
        Enum.zip(aliases, mines)
        |> Enum.into(%{}, fn pair -> pair end)
    end

    # must have our map to calculate. Don't call this by itself
    # use the our_info method to get both the map and the aliases
    def mine_aliases(our_current_tree, mines) do
        mines
        |> Enum.map(fn(mine) -> flatten_paths_for_aliases(mine,our_current_tree)end)
        |> Enum.map(fn(paths) -> Enum.uniq(List.flatten(paths)) end)
        |> build_alias_map(mines)
    end

    def flatten_paths_for_aliases(mine, our_current_tree) do
        our_current_tree
        |> Enum.reduce([], fn(path, a) ->
            case List.first(path) == mine do
                true -> [path | a]
                false -> a
            end
        end)
    end

    # assumes only ever plays mines
    # treats any site adjacent to a mine as a mine
    def onMoveMinePlaysOnly(game) do
        onMoveMinePlaysOnly(game, max_length(game))
    end

    # use this one to limit the cal
    def onMoveMinePlaysOnly(game, max_length) do
        id = game["id"]
        taken_ids = game
            |> Map.get(id, Map.new)
            |> Map.keys
        all_mines = taken_ids
            |> Enum.reduce(game["mines"], fn(taken, mines) -> [taken | mines] end)
            |> Enum.uniq
        start(all_mines, game["available"], max_length)
    end

    def find_mine_routes_to_specified_sites([], mines, acc) do
        acc
    end
    def find_mine_routes_to_specified_sites(tree = [head | tail], mines, acc) do
        case head in mines do
            true -> [tree | acc]
            false -> acc
        end
    end

    def find_mines_routes_not_ending_at_specific_sites([], mines, acc) do
        acc
    end
    def find_mines_routes_not_ending_at_specific_sites(tree = [head | tail], mines, acc) do
        case head in mines do
            false -> [tree | acc]
            true -> acc
        end
    end

    def add_tree_length_map(tree_length, tree, acc) do
        case Map.has_key?(acc, tree_length) do
            true ->  Map.put(acc, tree_length, [tree | Map.get(acc, tree_length)])
            false -> Map.put(acc, tree_length, [tree])
        end
    end

    def make_route_length_map(routes) do
        routes
        |> trees_mapped_by_length
    end

    def trees_mapped_by_length(trees) do
        trees
        |> Enum.reduce(%{}, fn(tree, a) -> add_tree_length_map(Enum.count(tree), tree, a) end)
    end

    def flatten_me(lol = [head | tail], acc) when is_list(head)  do
        lol
        |> Enum.reduce(acc, fn(item, a) -> flatten_me(item, a) end)
    end
    def flatten_me(terminal_list, acc) do
        [terminal_list| acc]
    end

    def update_score_keeper( mine_route, starting_mine, false) do
    end
    def update_score_keeper( mine_route, starting_mine, score_keeper) do
        ScoreKeeper.add_score(score_keeper, mine_route, starting_mine)
    end

    # acc is a list of sites in the path
    def check_for_subtrees(acc, site, edge_map, mines, max_length, starting_mine, score_keeper) do
        case (site in mines) && Enum.count(acc) != 1 do
            false -> edge_map
                |> Map.get(site)
                |> Enum.map(fn(next_site) -> build_tree(acc, next_site, edge_map, mines, max_length, starting_mine, score_keeper) end)
            true -> update_score_keeper(acc, starting_mine, score_keeper)
                acc
        end
    end
    def build_tree([], mine, edge_map, mines, max_length) do
        build_tree([], mine, edge_map, mines, max_length, false)
    end
    def build_tree([], mine, edge_map, mines, max_length, score_keeper) do
        case Enum.count(edge_map) == 0 do
            false -> [mine] |> check_for_subtrees(mine, edge_map, mines, max_length, mine, score_keeper)
            true -> []
        end
    end
    def build_tree(acc, site, edge_map, mines, max_length, starting_mine, score_keeper) do
        case site in acc || Enum.count(acc) > max_length do
            false -> [site | acc] |> check_for_subtrees(site, edge_map, mines, max_length, starting_mine, score_keeper)
            true -> update_score_keeper(acc, starting_mine, score_keeper)
                acc
        end
    end

end


