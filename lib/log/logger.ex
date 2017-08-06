defmodule Punting.Logger do
  def log(filename, message) do
    file = File.open!("#{System.get_pid}_#{filename}.log", [:append])
    IO.puts file, (DateTime.utc_now |> to_string) <>": " <> message
    File.close(file)
  end
  
end
