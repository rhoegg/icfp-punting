defmodule Punting.Player do
  use GenServer

  defstruct mode: nil, mode_state: nil, buffer: ""

  ### Server

  def start_link(mode) do
    GenServer.start_link(__MODULE__, {mode}, name: __MODULE__)
  end

  ### Client

  def init({mode}) do
    send(self(), :handshake)
    {:ok, %__MODULE__{mode: mode}}
  end

  def handle_info(:handshake, %{mode: mode} = player) do
    mode_state = mode.handshake("The Mikinators")
    send(self(), :process_message)
    {:noreply, %__MODULE__{player | mode_state: mode_state}}
  end

  def handle_info(
    :process_message,
    %{mode: mode, mode_state: mode_state, buffer: buffer} = player
  ) do
    message = mode.receive_message(mode_state)
    buffer  = buffer <> message
    buffer  = process_messages(buffer)
    send(self(), :process_message)
    {:noreply, %__MODULE__{player | buffer: buffer}}
  end

  ### Helpers

  defp process_messages(buffer) do
    case Punting.Parser.parse(buffer) do
      {nil, ^buffer} ->
        buffer
      {message, remainder} ->
        process_message(message)
        if remainder == "" do
          remainder
        else
          process_messages(remainder)
        end
    end
  end

  defp process_message(message) do
    IO.inspect(message)
  end
end
