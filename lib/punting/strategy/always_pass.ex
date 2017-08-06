defmodule Punting.Strategy.AlwaysPass do
  # [{source, target}, ...]
  def futures(_game) do
    [ ]
  end

  # Pass:  nil
  # Move:  {source, target}
  # Move:  [site_1, site_2, ...]
  def move(_game) do
    nil
  end
end
