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
        case :gen_tcp.recv(state.socket, 0) do
            {:ok, packet} ->
                send self(), parse(packet)
                send self(), {:recv, []}
                {:noreply, state}
            {:error, error} ->
                IO.puts("Error: #{error}")
                {:noreply, state}
        end
    end

    def handle_info({:handshake, %{player: player}}, state) do
        response = %{you: player}
        :gen_tcp.send(state.socket, encode(response))
        {:noreply, state}
    end

    defp parse(packet) do
        [_len | json] = String.split(packet, ":", parts: 2)
        parsed = Poison.decode!(json)
        %{"me" => player} = parsed
        {:handshake, %{player: player}}
    end

    defp encode(response) do
        json = Poison.encode!(response)
        len = String.length(json)
        "#{len}:#{json}"
    end

    # Client
    def start_link({id, socket}) do
        GenServer.start_link(__MODULE__, {id, socket})
    end
end