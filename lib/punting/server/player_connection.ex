defmodule Punting.Server.TcpServer.PlayerConnection do
    use GenServer
    defstruct ~w[id socket open]a

    def init({id, socket}) do
        state = %__MODULE__{
            id: id,
            socket: socket,
            open: nil
        }
        send self(), {:recv, []}
        {:ok, state}
    end

    def handle_info({:recv, _}, state) do

        case recv_msg(state.socket) do
            {:ok, msg} ->
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
        {:noreply, %{state | open: System.os_time(:millisecond)}}
    end

    def handle_call({:await_handshake, timeout}, {from, _}, state) do
        send self(), {:await_open, from, System.os_time(:millisecond) + timeout}
        {:reply, {:ok, nil}, state}
    end

    def handle_info({:await_open, from, deadline}, state) do

        if deadline < System.os_time(:millisecond) do
            GenServer.cast(from, {:handshake_completed, :timeout})
            {:noreply, state}
        else
            case state.open do
                nil -> 
                    send self(), {:await_open, from, deadline}
                    {:noreply, state, :hibernate}
                open -> 
                    GenServer.cast(from, {:handshake_completed, :ok, self()})
                    {:noreply, state}
            end
        end
    end

    def handle_info({:begin, %{players: players, map: map}}, state) do
        :gen_tcp.send(state.socket, encode(%{
            punters: players,
            map: map
        }))
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