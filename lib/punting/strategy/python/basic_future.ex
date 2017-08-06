defmodule Punting.Strategy.Isaac.BasicFutures do
    
    def futures(game) do
        PythonPhone.subscribe(self())
        PythonPhone.talk(%{
            strategy: __MODULE__ |> Module.split |> List.last,
            tag: __MODULE__,
            function: "bet",
            kwargs: %{max_mines_to_consider: 9},
            game: game,
            state: %{},
            comment: "Hello Isaac"
        })

        tag = Atom.to_string(__MODULE__)
        receive do
            {:reply, %{"tag" => tag} = msg} -> msg
        end
    end

    def move(game) do
        PythonPhone.subscribe(self())
        PythonPhone.talk(%{
            strategy: __MODULE__ |> Module.split |> List.last,
            tag: __MODULE__,
            function: "move",
            kwargs: %{},
            game: game,
            state: %{},
            comment: "Move Isaac"
        })

        tag = Atom.to_string(__MODULE__)
        receive do
            {:reply, %{"tag" => tag} = msg} -> msg
        end
    end
end