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
        {:ok, packet} = :gen_tcp.recv(state.socket, 0)
        msg = parse(packet)
        handshake msg, state.socket
        send self(), {:recv, []}
        {:noreply, state}
    end

    defp parse(packet) do
        [len | json] = String.split(packet, ":", parts: 2)
        parsed = Poison.decode!(json)
        %{"me" => player} = parsed
        {:handshake, %{player: player}}
    end

    defp handshake(msg, socket) do
        {:handshake, %{player: player}} = msg
        response = %{you: player}
        :gen_tcp.send(socket, encode(response))
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