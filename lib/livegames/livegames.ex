use Mix.Config

defmodule Livegames do
    def web_client() do
        Application.get_env(:live_games, :web_client) || Livegames.HTTPoisonWebClient
    end

    def list() do
        table_rows = web_client().get!("http://punter.inf.ed.ac.uk/status.html").body
        |> Floki.find("table tr")
        |> Enum.map( &( elem(&1, 2)) )

        table_rows
        |> Enum.filter( &has_td/1 )
        |> Enum.map( &to_game/1 )
    end

    def list_empty() do
        list()
        |> Enum.filter( &(&1.seats == 0) )
    end

    defp to_game(cells) do
        [
            {"td", _, [who]},
            _,
            {"td", _, [port_string]}
            | _ 
        ] = cells
        {status, open_count, player_count} = parse_who(who)
        %{
            players: player_count, 
            seats: open_count, 
            port: String.to_integer(port_string)
        }
    end

    def parse_who("Game in progress."), do: {"Game in progress", -1, -1}
    def parse_who(who) do
        %{"open" => open, "players" => players} = Regex.named_captures(
            ~r/Waiting for punters. \((?<open>\d+)\/(?<players>\d+)\)/, 
            who)
        {
            "Waiting for punters",
            String.to_integer(open),
            String.to_integer(players)
        }
    end

    def has_td([first | _]) do
        elem(first, 0) == "td"
    end
end