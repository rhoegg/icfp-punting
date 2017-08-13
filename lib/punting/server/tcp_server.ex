alias Punting.Server.TcpServer.PlayerConnection
alias Punting.Server.TcpServer.PlayerSupervisor

defmodule Punting.Server.TcpServer do
    use GenServer

    # Server 

    def init({ip, port}) do
        case :gen_tcp.listen(port, [:binary,{:packet, 0},{:active,false},{:ip,ip}]) do
            {:ok, listen_socket} ->
                send self(), {:accept, listen_socket}
                {:ok, {listen_socket, {ip, port}}}
            {:error, :eaddrinuse} ->
                {:error, "Address already in use"}
        end
    end

    def handle_info({:accept, listen_socket}, state) do
        {:ok, client_socket} = :gen_tcp.accept(listen_socket)

        PlayerSupervisor.start_worker(:foo, client_socket)

        send self(), {:accept, listen_socket}

        {:noreply, state}
    end

    # Client

    def start_link do
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

    def start do
        Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    def start_worker(id, socket) do
        Supervisor.start_child(__MODULE__, [{id, socket}])
    end    
end