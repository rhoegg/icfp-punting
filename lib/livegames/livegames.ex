use Mix.Config

defmodule Livegames do
    def web_client() do
        Application.get_env(:live_games, :web_client) || Livegames.HTTPoisonWebClient
    end

    def list() do
        table_rows = web_client().get!("http://punter.inf.ed.ac.uk/status.html").body
        |> Floki.find("table tr")
        |> Enum.map( &( elem(&1, 2)) )

        games = table_rows
        |> Enum.filter( &has_td/1 )
        |> Enum.map( &to_game/1 )

        attach_maps(games)
    end

    def list_empty() do
        list()
        |> Enum.filter( &(&1.players == 0) )
    end

    defp attach_maps(games) do
        Enum.reduce(games, {[], %{}}, fn(game, {games, cache}) ->
            {game, cache} = retrieve_map(game, cache)
            {[game | games], cache}
        end)
        |> elem(0)
    end

    defp retrieve_map(game, cache) do
        url = make_map_url(game.map_name)
        new_cache = case Map.has_key?(cache, url) do
            false -> Map.put(cache, url, web_client().get!(url))
            true -> cache
        end
        cached_game = Map.get(new_cache, url).body
        { Map.put(game, :map_json, cached_game), new_cache }
    end

    defp make_map_url(map_name) do
        "http://punter.inf.ed.ac.uk/maps/" <> map_name
    end

    defp to_game(cells) do
        [
            {"td", _, [who]},
            _,
            _,
            {"td", _, [port_string]},
            {"td", _, [{"a", _, [map_name]}]}
            | _
        ] = cells
        {status, player_count, seat_count} = parse_who(who)
        %{
            status: status,
            players: player_count,
            seats: seat_count, 
            port: String.to_integer(port_string),
            map_name: map_name
        }
    end

    def parse_who(who) do
        if String.match?(who, ~r/Waiting for punters. .*/) do
            %{"players" => players, "seats" => seats} = Regex.named_captures(
                ~r/Waiting for punters. \((?<players>\d+)\/(?<seats>\d+)\)/, 
                who)
            {
                "Waiting for punters",
                String.to_integer(players),
                String.to_integer(seats)
            }
        else
            {who, -1, -1}
        end
    end

    def has_td([first | _]) do
        elem(first, 0) == "td"
    end
end