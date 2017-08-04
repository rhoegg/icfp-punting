defmodule LivegamesTest do
  use ExUnit.Case
  
  setup do
      Application.put_env(:live_games, :web_client, LivegamesTest.TestWebClient)
  end

  test "lists games with ports" do
      games = Livegames.list()
      ports = games
      |> Enum.map( &(&1.port) )
      assert Enum.member?(ports, 9001)
  end
end

defmodule LivegamesTest.TestWebClient do
    @behaviour Livegames.WebClient
    def get!("http://punter.inf.ed.ac.uk/status.html") do
        contents = File.read!(Path.expand("data/game_list_example.html", __DIR__))
        %HTTPoison.Response{
            body: contents
        }
        |> IO.inspect
    end
    def get!(_) do
        %HTTPoison.Response{
            body: ""
        }
    end
 end