alias Punting.Server.TcpServer.PlayerConnection
alias Punting.Server.TcpServer.PlayerSupervisor

defmodule Punting.Server.TcpServer do
    use GenServer
    defstruct ~w[socket ip port players]a

    # Server 

    def init({ip, port}) do
        case :gen_tcp.listen(port, [:binary,{:packet, 0},{:active,false},{:ip,ip}]) do
            {:ok, listen_socket} ->
                send self(), {:accept, listen_socket}
                {:ok, %{socket: listen_socket, ip: ip, port: port, players: []}}
            {:error, :eaddrinuse} ->
                {:stop, "Couldn't listen on port #{port}: Address already in use"}
        end
    end

    def handle_info({:accept, listen_socket}, state) do
        {:ok, client_socket} = :gen_tcp.accept(listen_socket)

        {:ok, worker_pid} = PlayerSupervisor.start_worker(length(state.players), client_socket)

        players = [worker_pid | state.players]

        if length(players) < 2 do
            send self(), {:accept, listen_socket}
        else
            GenServer.cast self(), {:begin, players}
            IO.puts("TcpServer: sent begin announcement")
        end

        {:noreply, %{state | players: players}}
    end

    def handle_cast({:begin, players}, state) do
        IO.puts("TcpServer: Game starting...")
        Enum.each(players, fn pid ->
            IO.puts("TcpServer: Notifying game start for #{inspect(pid)}...")
            send pid, {:begin, %{players: length(players), map: %{name: "test"}}}
        end)
        IO.puts("TcpServer: notification seems done")
        {:noreply, state}
    end

    # Client

    def start_link(_args) do
            GenServer.start_link(__MODULE__,
                {
                    Application.get_env(:punting, :ip, {127,0,0,1}), 
                    Application.get_env(:punting, :port, 7190)
                })
    end

end

defmodule Punting.Server.TcpServer.PlayerSupervisor do
    use Supervisor

    def init(:ok) do
        children = [
            worker(PlayerConnection, [])
        ]

        supervise(children, strategy: :simple_one_for_one)
    end

    def start_link(_args) do
        Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    def start_worker(id, socket) do
        Supervisor.start_child(__MODULE__, [{id, socket}])
    end    
end