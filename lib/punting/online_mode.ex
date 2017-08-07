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
    case :gen_tcp.recv(socket, 10) do
      {:ok, header} ->
        case Integer.parse(header) do
          {size, ":" <> start_of_data} ->
            {:ok, rest_of_data} =
              :gen_tcp.recv(socket, size - byte_size(start_of_data))
            parse_json(start_of_data <> rest_of_data)
          _error ->
            raise "Error:  No message length"
        end
    end
  end

  def send_ready(%__MODULE__{socket: socket}, id, _state) do
    send_json(socket, %{"ready" => id})
  end
  def send_ready(%__MODULE__{socket: socket}, id, bets, _state) do
    send_json(socket, %{"ready" => id, "futures" => bets})
  end

  def send_move(%__MODULE__{socket: socket}, {id, source, target}, _state) do
    send_json(
      socket,
      %{"claim" => %{"punter" => id, "source" => source, "target" => target}}
    )
  end
  def send_move(%__MODULE__{socket: socket}, {id, route}, _state) do
    send_json(socket, %{"splurge" => %{"punter" => id, "route" => route}})
  end
  def send_move(%__MODULE__{socket: socket}, id, _state) do
    send_json(socket, %{"pass" => %{"punter" => id}})
  end

  def parse_json(json) do
    case Poison.decode(json) do
      {:ok, message} ->
        parse_message(message)
      _error ->
        raise "Error:  Invalid JSON"
    end
  end

  def parse_message(%{"you" => name}) do
    {:you, name}
  end
  def parse_message(
    %{"punter" => id, "punters" => punters, "map" => map} = setup
  ) do
    {:setup, id, punters, map, setup["settings"] || %{ }}
  end
  def parse_message(%{"move" => move} = message) do
    {:move, Map.fetch!(move, "moves"), message["state"]}
  end
  def parse_message(%{"stop" => moves_and_score} = message) do
    {
      :stop,
      Map.fetch!(moves_and_score, "moves"),
      Map.fetch!(moves_and_score, "scores"),
      message["state"]
    }
  end
  def parse_message(%{"timeout" => seconds}) do
    {:timeout, seconds}
  end

  defp send_json(socket, message) do
    json = Poison.encode!(message)
    :gen_tcp.send(socket, "#{byte_size(json)}:#{json}")
  end

  defp choose_port(nil) do
    case System.get_env("ICFP_PORT") do
      nil ->
        IO.puts "Please set ICFP_PORT."
        System.halt(1)
      port ->
        String.to_integer(port)
    end
  end
  defp choose_port(port) when is_integer(port) do
    port
  end
end
