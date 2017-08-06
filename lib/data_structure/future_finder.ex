defmodule Punting.DataStructure.FutureFinder do

    alias Punting.DataStructure.ScoreKeeper
# disable building routes from DataStructure
# Must call start from DataStructure
# needs to control data on the game object
    def find_future(game) do
        # starting_mine = pick_mine(game)
        {:ok, score_keeper} = Punting.DataStructure.ScoreKeeper.start()
        # starting_mine = 1
        starting_mine = Enum.random(game["mines"])
        max_length = (game["total_rivers"]) / (game["number_of_punters"] * 2)
        futures_length = (game["total_rivers"] * 3) / (game["number_of_punters"] * 7)
        all_trees = MineRoutes.build_trees([starting_mine], game["initial"], max_length, score_keeper)
        scores = ScoreKeeper.scores(score_keeper)
        median = median_score(scores)
        score_to_site_map = map_scores_from_one_mine_to_terminal_sites(scores)
        other_routes = MineRoutes.other_routes_mine_last(all_trees, game["mines"])
        routes_to_sites = map_routes_from_one_mine_to_terminal_sites(other_routes)
        routes_to_sites_info = number_routes_to_one_site(routes_to_sites, scores, starting_mine)
        # m2m_routes = MineRoutes.m2m_routes(all_trees, game["mines"])
        # mine_route_map = MineRoutes.make_route_length_map(m2m_routes)
        random_future = get_future(routes_to_sites_info, median, 5, starting_mine)
end

    def format_future({future_site, future_info}, mine) do
        %{}
        |> Map.put("mine", mine)
        |> Map.put("site", future_site)
        |> Map.put("routes", Map.get(future_info, "routes"))
    end

    def map_scores_from_one_mine_to_terminal_sites(scores) do
        acc = %{}
        Enum.reduce(scores, acc, fn({key, value}, a) ->
            [ _head, terminal_site] = String.split(key, "-")
            {terminal_site , _} =  terminal_site |> Integer.parse
            list_of_trips = Map.get(a, value)
            case list_of_trips == nil do
                true -> Map.put(a, value, [terminal_site])
                false -> Map.put(a, value, [terminal_site | list_of_trips])
            end
        end)
    end

    def median_score(scores) do
        acc = []
        list_of_scores = Enum.reduce(scores, acc, fn({key, value}, a) ->
            [value | a]
        end)
        score_length = Enum.count(list_of_scores)
        split_length = div(score_length,2)
        case score_length > 1 do
            true -> {lower_values, higher_values} =list_of_scores
                |> Enum.sort
                |> Enum.split(split_length)
                List.first(higher_values)
            false -> list_of_scores.first

        end
    end

    def get_future(info, median_score, ratio_threshold, mine) do
        possibles = possible_future(info, median_score, ratio_threshold)
        case possibles == [] && median_score > 4 do
            true -> get_future(info, median_score - 1, ratio_threshold, mine)
            false -> random_future(possibles, mine)
        end
    end

    def random_future([], mine) do
        nil
    end
    def random_future(possibles, mine) do
        possibles
        |> Enum.random
        |> format_future(mine)
    end

    def possible_future(info, median_score, ratio_threshold) do
        info
        |> Enum.filter(fn({key, site}) ->
            ratio = div(site["number_or_routes"], site["min_hops"])
            site["score_to_route"] >= median_score && ratio >= ratio_threshold
        end)
    end

    # assumes all routes end at same mine
    def map_routes_from_one_mine_to_terminal_sites(routes) do
        acc = %{}
        Enum.reduce(routes, acc, fn(route = [ finish | _tail], a) ->
            list_of_sites = Map.get(a, finish)
            case list_of_sites == nil do
                true -> Map.put(a, finish, [route])
                false -> Map.put(a, finish, [route | list_of_sites])
            end
        end)
    end

    def number_routes_to_one_site(route_map, scores, mine) do
        Enum.reduce(route_map, %{}, fn({key, value}, a) ->
            score = Map.get(scores, ScoreKeeper.make_id(mine, key))
            info = %{
                "number_or_routes" => Enum.count(value),
                "score_to_route" => score,
                "min_hops" => :math.sqrt(score) |> round,
                "routes" => value
            }
            Map.put(a, key, info) end)
    end
end