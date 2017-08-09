defmodule Punting.Server.TcpServerTest do
  alias Punting.Server.TcpServer

  use ExUnit.Case, async: true
  
  @moduletag :functional

  test "handshake captures player name" do
    IO.puts("Test: starting TcpServer...")
    {:ok, _server} = TcpServer.start_link

    _host = Application.get_env :punting, :ip
    port = Application.get_env :punting, :port
    IO.puts("Test: connecting...")
    {:ok, socket} = :gen_tcp.connect("localhost", port,
      active: false, mode: :binary, packet: :raw)
    IO.puts("Test: connected.")

    msg = Poison.encode!(%{"me" => "test runner"})
    :gen_tcp.send(socket, "#{byte_size(msg)}:#{msg}\n")
    IO.puts("Test: handshake sent.")
    received = case :gen_tcp.recv(socket, 10) do
        {:ok, header} ->
            case Integer.parse(header) do
                {size, ":" <> start_of_data} ->
                    {:ok, rest_of_data} =
                        :gen_tcp.recv(socket, size - byte_size(start_of_data))
                        start_of_data <> rest_of_data
                _error ->
                    raise "Error: No message length"
            end
    end
    IO.puts("Test: handshake received.")

    assert Poison.decode!(received) == %{"you" => "test runner"}

  end
end