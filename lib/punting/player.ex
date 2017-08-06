defmodule Punting.Player do
  use GenServer
  require Logger

  defstruct mode:       nil,
            mode_arg:   nil,
            mode_state: nil,
            strategy:   Punting.Strategy.BasicMineConnections,
            scores:     :halt,
            game:       nil

  ### Server

  def start_link(mode, options \\ [ ]) do
    GenServer.start_link(
      __MODULE__,
      {mode, options[:mode_arg], options[:scores] || :halt, options[:strategy]}
    )
  end

  ### Client

  def init({mode, mode_arg, scores, strategy}) do
    send(self(), :handshake)
    {:ok, %__MODULE__{mode: mode, mode_arg: mode_arg, scores: scores, strategy: strategy}}
  end

  def handle_info(:handshake, %{mode: mode, mode_arg: mode_arg} = player) do
    mode_state = mode.handshake(mode_arg, "The Mikinators")
    send(self(), :process_message)
    {:noreply, %__MODULE__{player | mode_state: mode_state}}
  end

  def handle_info(
    :process_message,
    %{mode: mode, mode_state: mode_state} = player
  ) do
    message = mode.receive_message(mode_state)
    Logger.debug "IN:  #{inspect message}"
    new_game = process_message(message, player)
    case message do
      {:stop, _moves, _scores, _state} ->
        {:stop, :normal, nil}
      _non_stop_message ->
        send(self(), :process_message)
        {:noreply, %__MODULE__{player | game: new_game}}
    end
  end

  ### Helpers

  defp process_message({:setup, _id, _punters, _map} = setup, player) do
    new_game = DataStructure.process(setup)
    Logger.debug "OUT:  ready #{new_game["id"]}"
    player.mode.send_ready(player.mode_state, new_game["id"], new_game)
    new_game
  end
  defp process_message({:move, moves, state}, player) do
    new_game = DataStructure.process({:move, moves, state || player.game})
    move =
      case strategy_move(player.strategy).(new_game) do
        nil              -> new_game["id"]
        {source, target} -> {new_game["id"], source, target}
        bad_move                -> raise "Error:  Bad strategy:  #{player.strategy} produced move #{IO.inspect(bad_move)}"
      end
    Logger.debug "OUT:  move #{inspect move}"
    player.mode.send_move(player.mode_state, move, new_game)
    new_game
  end
  defp process_message({:stop, moves, scores, state}, player) do
    result = {:result, moves, player.game["id"], scores, state}
    case player.scores do
      pid when is_pid(pid) ->
        send(pid, result)
      :halt ->
        IO.inspect(result)
        System.halt
    end
    player.game
  end
  defp process_message(_message, player), do: player.game

  defp strategy_move(strategy) do
    case IO.inspect(strategy) do
      module when is_atom(module) -> fn game -> module.move(game) end
      f      when is_function(f)  -> f.(:move)
    end
  end
end
