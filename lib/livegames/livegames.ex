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
        |> Enum.map(fn(cells) -> 
                [
                    {"td", _, [who]},
                    _,
                    {"td", _, [port_string]}
                    | _ 
                ] = cells
                %{players: who, port: String.to_integer(port_string)}
            end)
        |> IO.inspect
    end

    def has_td([first | _]) do
        elem(first, 0) == "td"
    end
end