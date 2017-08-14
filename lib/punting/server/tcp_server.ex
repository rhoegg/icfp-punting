alias Punting.Server.TcpServer.PlayerConnection
alias Punting.Server.TcpServer.PlayerSupervisor

defmodule Punting.Server.TcpServer do
    use GenServer
    defstruct ~w[socket ip port name map status players workers]a

    # Server 

    def init({ip, port, players, map}) do
        case :gen_tcp.listen(port, [:binary,{:packet, 0},{:active,false},{:ip,ip}]) do
            {:ok, listen_socket} ->
                map_data = load_map(map)
                send self(), {:accept, listen_socket}
                {:ok, %{
                    socket: listen_socket, 
                    ip: ip, 
                    port: port, 
                    name: map, 
                    map: map_data, 
                    status: "Waiting for punters. (0/#{players})",
                    players: players, 
                    workers: []
                    }
                }
            {:error, :eaddrinuse} ->
                {:stop, "Couldn't listen on port #{port}: Address already in use"}
        end
    end

    def handle_call({:status}, _from, state) do
        {:reply, state.status, state}
    end

    def handle_info({:accept, listen_socket}, state) do
        case :gen_tcp.accept(listen_socket, 250) do
            {:ok, client_socket} ->
                {:ok, worker_pid} = PlayerSupervisor.start_worker(length(state.workers), client_socket)
                {:ok, _} = GenServer.call(worker_pid, {:await_handshake, 2000})
            {:error, :timeout} ->
                send self(), {:accept, listen_socket}
        end

        {:noreply, state}
    end

    def handle_cast({:handshake_completed, :ok, worker}, state) do
        workers = [worker | state.workers]

        status = if length(workers) < state.players do
            send self(), {:accept, state.socket}
            "Waiting for punters. (#{length(workers)}/#{state.players})"
        else
            GenServer.cast self(), {:begin, workers}
            "Starting"
        end

        {:noreply, %{state | workers: workers, status: status}}
    end

    def handle_cast({:handshake_completed, result}, state) do
        send self(), {:accept, state.socket}
        {:noreply, state}
    end

    def handle_cast({:begin, workers}, state) do
        Enum.each(workers, fn pid ->
            send pid, {:begin, %{players: state.players, map: state.map}}
        end)
        {:noreply, state}
    end

    defp load_map(name) do
        :code.priv_dir(:punting)
        |> Path.join("maps")
        |> Path.join("#{name}.json")
        |> File.read!
        |> Poison.decode!
    end

    # Client

    def start_link({players, map}) do
            GenServer.start_link(__MODULE__,
                {
                    Application.get_env(:punting, :ip, {127,0,0,1}), 
                    Application.get_env(:punting, :port, 7190),
                    players,
                    map
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