Code.require_file("bin/experimental_strategies.ex")

{options, _, _} = OptionParser.parse(System.argv, aliases: [m: :map, i: :iterations])
map = Keyword.get(options, :map)
iterations = Keyword.get(options, :iterations)

if iterations do
  strategies = 
    Compete.Experiment.base_strategies()
    |> Map.to_list
    |> Enum.concat(Compete.Experiment.spice_up(4))
    |> Enum.shuffle
  Compete.Experiment.run_generation(strategies, map, String.to_integer(iterations))
  |> Enum.each(fn result -> 
    if result do
      IO.puts(Compete.Experiment.pretty_result(result) <> "\n\n")
    end
  end)
else
  Compete.Experiment.run_one_empty(map)
end
