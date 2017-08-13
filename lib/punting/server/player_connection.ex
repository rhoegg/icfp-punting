defmodule Punting.Server.TcpServer.PlayerConnection do
    use GenServer
    defstruct ~w[id socket]a

    def init({id, socket}) do
        state = %__MODULE__{
            id: id,
            socket: socket
        }
        send self(), {:recv, []}
        {:ok, state}
    end

    def handle_info({:recv, _}, state) do

        case recv_msg(state.socket) do
            {:ok, msg} ->
                IO.puts("PlayerConnection: Received packet")
                send self(), parse(msg)
                send self(), {:recv, []}
                {:noreply, state}
            {:timeout, _} ->
                send self(), {:recv, []}
                {:noreply, state}
            {:error, error} ->
                IO.puts("PlayerConnection Error: #{error}")
                {:noreply, state}
        end
    end

    def handle_info({:handshake, %{player: player}}, state) do
        response = %{you: player}
        :gen_tcp.send(state.socket, encode(response))
        {:noreply, state}
    end

    def handle_info({:begin, %{players: players, map: _map}}, state) do
        IO.puts("Beginning game for player #{state.id}")
        :gen_tcp.send(state.socket, encode(%{
            punters: players,
            fake: "fakefakefakefake"
        }))
        IO.puts("Began game for player #{state.id}")
        {:noreply, state}
    end

    defp parse(json) do
        parsed = Poison.decode!(json)
        %{"me" => player} = parsed
        {:handshake, %{player: player}}
    end

    defp encode(response) do
        json = Poison.encode!(response)
        len = String.length(json)
        "#{len}:#{json}"
    end

    defp recv_msg(socket, timeout \\ 500) do
      case :gen_tcp.recv(socket, 10, timeout) do
          {:ok, header} ->
            case Integer.parse(header) do
                {size, ":" <> start_of_data} ->
                  {:ok, rest_of_data} =
                    :gen_tcp.recv(socket, size - byte_size(start_of_data))
                    {:ok, start_of_data <> rest_of_data}
                  _error ->
                      raise "Error: No message length"
              end
          {:error, :timeout} ->
            {:timeout, ""}
          {:error, error} ->
            {:error, error}
      end  
    end

    # Client
    def start_link({id, socket}) do
        GenServer.start_link(__MODULE__, {id, socket})
    end
end