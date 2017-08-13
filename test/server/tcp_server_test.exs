alias Punting.Server.TcpServer
alias Punting.Server.TcpServer.PlayerSupervisor

defmodule Punting.Server.TcpServerTest do

  use ExUnit.Case, async: true
  
  @moduletag :functional

  test "handshake captures player name" do
    {:ok, _sup_pid} = start_supervised(PlayerSupervisor)
    {:ok, _pid} = start_supervised(TcpServer)

    {_socket, received} = connect_and_handshake("test runner")
    assert Poison.decode!(received) == %{"you" => "test runner"}
  end

  test "game state sent to all players" do
    {:ok, _sup_pid} = start_supervised(PlayerSupervisor)
    {:ok, _pid} = start_supervised(TcpServer)

    # each player should get the game state once all players have connected
    {socket1, _resp1} = connect_and_handshake("punter1")
    {socket2, _resp2} = connect_and_handshake("punter2")

    game1_msg = recv_msg(socket1)
    game2_msg = recv_msg(socket2)
    
    game1 = Poison.decode!(game1_msg)
    game2 = Poison.decode!(game2_msg)

    assert Map.get(game1, "punters") == 2
    assert Map.get(game2, "punters") == 2
  end

  defp connect_and_handshake(player) do
    _host = Application.get_env :punting, :ip
    port = Application.get_env :punting, :port

    IO.puts("Test: connecting...")
    {:ok, socket} = :gen_tcp.connect('localhost', port,
      active: false, mode: :binary, packet: :raw)
    IO.puts("Test: connected.")

    msg = Poison.encode!(%{"me" => player})
    :gen_tcp.send(socket, "#{byte_size(msg)}:#{msg}\n")
    IO.puts("Test: handshake sent.")
    received = recv_msg(socket)
    IO.puts("Test: handshake received.")
    {socket, received}
  end

  defp recv_msg(socket, timeout \\ 10000) do
    case :gen_tcp.recv(socket, 10, timeout) do
        {:ok, header} ->
            case Integer.parse(header) do
                {size, ":" <> start_of_data} ->
                    {:ok, rest_of_data} =
                        :gen_tcp.recv(socket, size - byte_size(start_of_data))
                        start_of_data <> rest_of_data
                _error ->
                    raise "Error: No message length"
            end
        {:error, :timeout} ->
          flunk "Timed out waiting for server response"
    end  
  end
end