defmodule Punting.Parser do
  def parse(data) do
    data
    |> extract_message
    |> build_result
  end

  defp extract_message(data) do
    with {:ok, n, header_size}  <- find_message_size(data),
         {:ok, json, remainder} <- read_message(n, header_size, data) do
      {json, remainder}
    end
  end

  defp build_result({:error, _message, data}), do: {nil, data}
  defp build_result({json, remainder}) do
    case Poison.decode(json) do
      {:ok, raw} -> {parse_message(raw), remainder}
      _errorr    -> raise "Error:  Invalid JSON"
    end
  end

  defp find_message_size(data) do
    case Regex.run(~r{\A(\d+):}, data, capture: :all_but_first) do
      [n] -> {:ok, String.to_integer(n), byte_size(n) + 1}
      nil -> {:error, :no_length, data}
      _   -> raise "Error: Too many captures"
    end
  end

  defp read_message(n, header_size, data)
  when byte_size(data) < header_size + n,
    do: {:error, :not_enough_data, data}
  defp read_message(n, header_size, data) do
    {
      String.slice(data, header_size, n),
      String.slice(data, (header_size + n)..-1)
    }
  end

  defp parse_message(%{"punter" => id, "punters" => punters, "map" => map}) do
    {:setup, id, punters, map}
  end
  defp parse_message(%{"move" => move} = message) do
    {:move, Map.fetch!(move, "moves"), message["state"]}
  end
  defp parse_message(%{"stop" => moves_and_score} = message) do
    {
      :stop,
      Map.fetch!(moves_and_score, "moves"),
      Map.fetch!(moves_and_score, "scores"),
      message["state"]
    }
  end
end
