defmodule Punting.Strategy.AlwaysPass do
  # [{source, target}, ...]
  def futures(_game) do
    [ ]
  end

  # Pass:  nil
  # Move:  {source, target}
  def move(_game) do
    nil
  end
end
