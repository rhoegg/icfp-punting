defmodule PythonPhone do
    use GenServer
    defstruct ~w[process buffer listeners]a

    # Client

    def start_link do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(_args) do
      state =
        %__MODULE__{
          process: fire_it_up(),
          buffer: [],
          listeners: MapSet.new
        }
        {:ok, state}
    end

    def fire_it_up do
        cmd = "python3"
        program = "priv/pylib/move_server.py"
        Porcelain.spawn_shell(
            cmd <> " " <> program, 
            in: :receive, 
            out: {:send, self()}
        )
    end

    def subscribe(pid) do
        GenServer.cast(__MODULE__, {:subscribe, pid})
    end

    def talk(msg) do
        GenServer.cast(__MODULE__, {:talk, msg})
    end

    def marshal(msg) do
        Poison.encode!(msg)
    end

    def unmarshal(msg) do
        Poison.decode!(msg)
    end

    # Server

    def handle_cast({:talk, msg}, state) do
        out = marshal(msg)

        state.process
        |> Porcelain.Process.send_input(out <> "\n")
        {:noreply, state}
    end

    def handle_cast({:subscribe, pid}, state) do
        new_state = %{
            state
            | listeners: MapSet.put(state.listeners, pid)
        }
        {:noreply, new_state}
    end

    def handle_info({_pid, :data, :out, data}, state) do
        msg = unmarshal(data)
        Enum.each(state.listeners, fn listener ->
            send listener, {:reply, msg}
        end)
        {:noreply, state}
    end
end
