defmodule Punting.OfflineMode do
  defstruct ~w[name]a

  def handshake(nil, name) do
    send_message(%{"me" => name})
    %__MODULE__{name: name}
  end

  def receive_message(%__MODULE__{name: name}) do
    handshake(nil, name)
    IO.read(:all)
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

  defp send_message(message, state \\ nil)
  defp send_message(message, nil) do
    json = Poison.encode!(message)
    IO.write("#{byte_size(json)}:#{json}")
  end
  defp send_message(message, state) do
    send_message(Map.put(message, "state", serialize(state)), nil)
  end

  def serialize(term) do
    term
    |> :erlang.term_to_binary
    |> Base.encode64
  end

  def deserialize(binary) do
    binary
    |> Base.decode64!
    |> :erlang.binary_to_term
  end
end
