defmodule PythonPhone do
    use GenServer
    defstruct ~w[port buffer]a

    def start_link do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(_args) do
      state =
        %__MODULE__{
          port: fire_it_up(),
          buffer: [],
        }
        IO.puts("PythonPhone starting up!")
        {:ok, state}
    end

    def fire_it_up do
        Port.open({:spawn, "python3 ./priv/pylib/echo_stdio.py"}, [:stream, :binary])
    end

    def talk(msg) do
        GenServer.cast(__MODULE__, {:talk, msg})
    end

    def handle_cast({:talk, msg}, state) do
        IO.puts("Trying to talk #{msg}")
        Port.command(state.port, msg <> "\n")
        {:noreply, state}
    end

    def listen(lines \\ 1, partial \\ "") do
        IO.puts("Listening...")
        {clean, messages} = receive do
            {_, {:data, data}} -> 
                {
                    String.ends_with?(data, "\n"),
                    String.split(partial <> data, "\n")
                }
        end
        IO.puts("Got stuff #{messages}")

        complete_messages = 
            Enum.count(messages) - (if clean, do: 0, else: 1)

        if complete_messages >= lines do
            messages
        else
            listen(lines, (if clean, do: "", else: tl(messages)))
        end
    end

    def echo do
        talk("{ \"thing\": \"echo\"}")
        listen(1)
    end
end
