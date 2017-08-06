defmodule PuntingTest.Strategy.NeverTwoThree do
  def use?(_game) do
    false
  end

  def move(_game) do
    {2, 3}
  end
end

defmodule PuntingTest.Strategy.AlwaysOneTwo do
  def use?(_game) do
    true
  end

  def move(_game) do
    {1, 2}
  end
end

defmodule PuntingTest.Strategy.AlwaysSixSeven do
  def use?(_game) do
    true
  end

  def move(_game) do
    {6, 7}
  end
end

defmodule PuntingTest.Strategy.NoUseFunction do
  def move(_game) do
    {42, 43}
  end
end