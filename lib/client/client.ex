defmodule Client do
  def connection(server,port) do
    {:ok, _socket} = :gen_tcp.connect(server,port,[])
  end

  def recv(server) do
    :gen_tcp.recv(server, 0)
  end

  def send_my_name(server, my_name) do
    :gen_tcp.send(server, '{"me": "#{my_name}"}\n')
  end
  
end
