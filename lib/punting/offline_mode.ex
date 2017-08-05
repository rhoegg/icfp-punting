defmodule Punting.OfflineMode do
  defstruct ~w[name]a

  def handshake(nil, name) do
    %__MODULE__{name: name}
  end

  def receive_message(%__MODULE__{name: name}) do
    send_message(%{"me" => name})
    read_message()  # discard "You" message
    read_message()
  end

  def send_ready(_mode_state, id, state) do
    send_message(%{"ready" => id}, state)
  end

  def send_move(_mode_state, {id, source, target}, state) do
    send_message(
      %{"claim" => %{"punter" => id, "source" => source, "target" => target}},
      state
    )
  end
  def send_move(_mode_state, id, state) do
    send_message(%{"pass" => %{"punter" => id}}, state)
  end

  defp read_message do
    {:ok, header} = IO.read(10)
    case Integer.parse(header) do
      {size, ":" <> start_of_data} ->
        {:ok, rest_of_data} =
          IO.read(size - byte_size(start_of_data))
        file = File.open!("input.log", [:append])
        IO.puts file, (DateTime.utc_now |> to_string)
        IO.puts file, start_of_data <> rest_of_data
        File.close(file)
        Punting.OnlineMode.parse_json(start_of_data <> rest_of_data)
        |> deserialize_state
      _error ->
        raise "Error:  No message length"
    end
  end

  defp send_message(message, state \\ nil)
  defp send_message(message, nil) do
    json = Poison.encode!(message)
    file = File.open!("output.log", [:append])
    IO.puts file, (DateTime.utc_now |> to_string)
    IO.puts file, json
    File.close(file)
    IO.write("#{byte_size(json)}:#{json}")
  end
  defp send_message(message, state) do
    send_message(Map.put(message, "state", serialize(state)), nil)
  end

  defp serialize(term) do
    term
    |> :erlang.term_to_binary
    |> Base.encode64
  end

  defp deserialize(binary) do
    binary
    |> Base.decode64!
    |> :erlang.binary_to_term
  end

  defp deserialize_state({:move, moves, state}) do
    {:move, moves, deserialize(state)}
  end
  defp deserialize_state({:stop, moves, scores, state}) do
    {:stop, moves, scores, deserialize(state)}
  end
  defp deserialize_state(message), do: message
end
