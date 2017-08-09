defmodule Punting.Server.TcpServer do
    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__, 
            {
                Application.get_env(:punting, :ip, {127,0,0,1}), 
                Application.get_env(:punting, :port, 7190)
            })
    end

    def init({ip, port}) do
        IO.puts("TCP Server: Listening...")
        {:ok, listen_socket} = :gen_tcp.listen(port, [:binary,{:packet, 0},{:active,true},{:ip,ip}])
        IO.puts("TCP Server: Accepting Connection...")
        # looks like we should spawn child processes that each handle 1 player
        {:ok, socket} = :gen_tcp.accept listen_socket
        IO.puts("TCP Server: Accepted Connection...")
        {:ok, %{ip: ip, port: port, socket: socket}}
    end

    def handle_info({:tcp, _socket, _packet}, state) do
        IO.puts("well shucks")
        {:noreply, state}
    end

    def handle_info({:tcp_closed, _socket}, state) do
        IO.puts("bye felicia")
        {:noreply, state}
    end

    def handle_info({:tcp_error, _socket, _reason}, state) do
        IO.puts("damn")
        {:noreply, state}
    end
end