defmodule Punting.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, args) do
    if System.get_env("ICFP_VERBOSE") do
      Logger.configure(level: :debug)
    else
      Logger.configure(level: :error)
    end

    mode =
      if System.get_env("ICFP_PORT") do
        Punting.OnlineMode
      else
        Punting.OfflineMode
      end

    name     = System.get_env("ICFP_STRATEGY")
    strategy =
      if name do
        try do
          String.to_existing_atom("Elixir.Punting.Strategy.#{name}")
        rescue
          ArgumentError ->
            Punting.Strategy.AlwaysPass
        end
      else
        Punting.Strategy.AlwaysPass
      end

    # List all child processes to be supervised
    children =
      case args do
        [:prod] -> [{Punting.Player, mode: mode, strategy: strategy}]
        _       -> [ ]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Punting.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
