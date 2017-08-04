defmodule ParserTest do
  use ExUnit.Case, async: true

  setup _context do
    payload = %{"move" => %{"moves" => [ ]}}
    json    = Poison.encode!(payload)
    message = "#{byte_size(json)}:#{json}"
    {:ok, message: message}
  end

  test "extracts a message", %{message: message} do
    assert {:move, [ ], nil} = message |> Punting.Parser.parse |> elem(0)
  end

  test "returns the remainder of the data", %{message: message} do
    assert "" = message |> Punting.Parser.parse |> elem(1)
  end

  test "returns the data if a message can't be extracted" do
    assert {nil, ""} = Punting.Parser.parse("")
    assert {nil, "13"} = Punting.Parser.parse("13")  # no :
  end

  test "returns the data when we don't have the full packet",
      %{message: message} do
    short_message = message |> String.slice(0..-2)
    assert {nil, ^short_message} = Punting.Parser.parse(short_message)
  end
end
