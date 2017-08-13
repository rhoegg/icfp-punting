defmodule LivegamesFunctionalTest do
  use ExUnit.Case, async: true
  
  @moduletag :icfp

  test "lists games with ports" do
      games = Livegames.list()
      ports = games
      |> Enum.map( &(&1.port) )
      assert Enum.member?(ports, 9001)
  end

  test "games have maps" do
      games = Livegames.list()
      map_json = games
      |> Enum.map( &(&1.map_json) )
      assert ! Enum.any?( map_json, &(byte_size(&1) == 0) )
  end
end
