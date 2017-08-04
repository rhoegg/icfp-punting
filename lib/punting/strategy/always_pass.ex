defmodule Punting.Strategy.AlwaysPass do
  # Pass:  nil
  # Move:  {source, target}
  def move(_game) do
    nil
  end
end
