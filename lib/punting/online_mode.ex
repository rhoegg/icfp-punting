defmodule Punting.OnlineMode do
  defstruct ~w[socket]a

  @server 'punter.inf.ed.ac.uk'

  def handshake(port, name) do
    {:ok, socket} = :gen_tcp.connect(
      @server,
      choose_port(port),
      active: false, mode: :binary, packet: :raw
    )
    send_json(socket, %{"me" => name})
    %__MODULE__{socket: socket}
  end

  def receive_message(%__MODULE__{socket: socket}) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  def send_ready(%__MODULE__{socket: socket}, id, _state) do
    send_json(socket, %{"ready" => id})
  end

  def send_move(%__MODULE__{socket: socket}, {id, source, target}, _state) do
    send_json(
      socket,
      %{"claim" => %{"punter" => id, "source" => source, "target" => target}}
    )
  end
  def send_move(%__MODULE__{socket: socket}, id, _state) do
    send_json(socket, %{"pass" => %{"punter" => id}})
  end

  defp send_json(socket, message) do
    json = Poison.encode!(message)
    :gen_tcp.send(socket, "#{byte_size(json)}:#{json}")
  end

  defp choose_port(nil) do
    System.get_env("ICFP_PORT")
    |> String.to_integer
  end
  defp choose_port(port) when is_integer(port) do
    port
  end
end
