
defmodule TestServer do
  def open do
    {:ok, socket} = :gen_tcp.listen(1234,
                                    [:binary, active: false, 
                                     reuseaddr: true])
    socket
  end

  def accept(socket) do
    {:ok, sock } = :gen_tcp.accept(socket)
    sock
  end

  def recv_forever(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    IO.puts data
    socket |> recv_forever()
  end


end

TestServer.open
|> TestServer.accept
|> TestServer.recv_forever
