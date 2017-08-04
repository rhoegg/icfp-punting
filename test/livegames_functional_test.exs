defmodule LivegamesFunctionalTest do
  use ExUnit.Case, async: true
  
  @moduletag :functional

  test "lists games with ports" do
      games = Livegames.list()
      ports = games
      |> Enum.map( &(&1.port) )
      assert Enum.member?(ports, 9001)
  end
end
