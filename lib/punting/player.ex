defmodule Punting.Player do
  use GenServer
  require Logger

  defstruct mode:       nil,
            mode_arg:   nil,
            mode_state: nil,
            strategy:   Punting.Strategy.BackToTheFuture,
            scores:     :halt,
            game:       nil,
            futures:    false

  ### Server

  def start_link(options \\ [ ]) do
    GenServer.start_link(
      __MODULE__,
      {
        options[:mode],
        options[:mode_arg],
        options[:scores]   || :halt,
        options[:strategy] || Punting.Strategy.BackToTheFuture
      }
    )
  end

  ### Client

  def init({mode, mode_arg, scores, strategy}) do
    send(self(), :handshake)
    {
      :ok,
      %__MODULE__{
        mode:     mode,
        mode_arg: mode_arg,
        scores:   scores,
        strategy: strategy
      }
    }
  end

  def handle_info(:handshake, %{mode: mode, mode_arg: mode_arg} = player) do
    mode_state = mode.handshake(mode_arg, "Techlahoma Practice")
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
      other_message ->
        new_futures =
          if is_tuple(other_message) && elem(other_message, 0) == :setup do
            elem(other_message, 4)["futures"]
          end
        send(self(), :process_message)
        {:noreply, %__MODULE__{player | game: new_game, futures: new_futures}}
    end
  end

  ### Helpers

  defp process_message({:setup, id, punters, map, settings}, player) do
    new_game =
      DataStructure.process({:setup, id, punters, map}, settings["splurges"])
    game_with_futures =
      if settings["futures"] do
        bets =
          case strategy_futures(player.strategy) do
            nil -> [ ]
            f   -> f.(new_game)
          end
        Logger.debug "OUT:  ready #{new_game["id"]} #{inspect bets}"
        player.mode.send_ready(
          player.mode_state,
          new_game["id"],
          Enum.map(bets, fn {s, t} -> %{"source" => s, "target" => t} end),
          new_game
        )
        DataStructure.add_futures(new_game, bets)
      else
        Logger.debug "OUT:  ready #{new_game["id"]}"
        player.mode.send_ready(player.mode_state, new_game["id"], new_game)
        new_game
      end
    game_with_futures
  end
  defp process_message({:move, moves, state}, player) do
    new_game = DataStructure.process({:move, moves, state || player.game})
    move =
      case strategy_move(player.strategy).(new_game) do
        nil                       -> new_game["id"]
        {source, target}          -> {new_game["id"], source, target}
        route when is_list(route) -> {new_game["id"], route}
        bad_move                  ->
          raise "Error:  Bad strategy:  #{player.strategy} " <>
                "Produced move:  #{inspect(bad_move)}"
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
        System.halt
    end
    player.game
  end
  defp process_message(_message, player), do: player.game

  defp strategy_futures(strategy) do
    case strategy do
      module when is_atom(module) ->
        if Enum.member?(module.__info__(:functions), {:futures, 1}) do
          fn game -> module.futures(game) end
        else
          nil
        end
      f when is_function(f) ->
        f.(:futures)
    end
  end

  defp strategy_move(strategy) do
    case strategy do
      module when is_atom(module) -> fn game -> module.move(game) end
      f      when is_function(f)  -> f.(:move)
    end
  end
end
