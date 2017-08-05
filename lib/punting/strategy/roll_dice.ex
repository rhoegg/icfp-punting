defmodule Punting.Strategy.RollDice do
    use GenServer

  defstruct ~w[target sides success fail seed]a

  # Client
  def strategy(target, sides, success, fail, seed \\ nil) do
    {:ok, roller} = start_link(target, sides, success, fail, seed)
    fn :move ->
        fn game -> move(roller, game) end
    end
  end

  def start_link(target, sides, success, fail, seed) do
    GenServer.start_link(__MODULE__, {target, sides, success, fail, seed})
  end

  def move(roller, game) do
    GenServer.call(roller, {:move, game})
  end

  # Server

  def init({target, sides, success, fail, seed}) do
    state =
      %__MODULE__{
        target: target, 
        sides: sides, 
        success: success, 
        fail: fail,
        seed: seed || :random.seed(:os.timestamp)}
    {:ok, state}
  end

  def handle_call({:move, game}, _from, state) do
    {roll, new_seed} = :rand.uniform_s(state.sides, IO.inspect(state.seed))
    strategy =
      if IO.inspect(roll) >= state.target do
        state.success
      else
        state.fail
      end
    move = strategy.move(game)
    { :reply, move, %{state | seed: new_seed} }
  end
end
