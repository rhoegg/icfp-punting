defmodule Punting.Player do
  use GenServer

  defstruct mode: nil, mode_state: nil, buffer: "", game: nil

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
    message    = mode.receive_message(mode_state)
    new_player = process_messages(buffer <> message, player)
    send(self(), :process_message)
    {:noreply, new_player}
  end

  ### Helpers

  defp process_messages(buffer, player) do
    case Punting.Parser.parse(buffer) do
      {nil, ^buffer} ->
        %__MODULE__{player | buffer: buffer}
      {message, remainder} ->
        new_game = process_message(message, player)
        if remainder == "" do
          %__MODULE__{player | buffer: "", game: new_game}
        else
          process_messages(remainder, player)
        end
    end
  end

  defp process_message({:setup, _id, _punters, _map} = setup, player) do
    new_game = DataStructure.process(setup)
    player.mode.send_ready(player.mode_state, new_game["id"], new_game)
    new_game
  end
  defp process_message({:move, moves, state}, player) do
    new_game = DataStructure.process({:move, moves, state || player.game})
    player.mode.send_move(player.mode_state, new_game["id"], new_game)# FIXME
    new_game
  end
  defp process_message(message, player) do
    IO.inspect(message)
    if is_tuple(message) && elem(message, 0) == :stop do
      System.halt
    end
    player
  end
end
