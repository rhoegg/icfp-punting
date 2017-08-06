Code.require_file("bin/experimental_strategies.ex")

{options, _, _} = OptionParser.parse(System.argv, aliases: [m: :map, i: :iterations])
map = Keyword.get(options, :map, "sample.json")
iterations = Keyword.get(options, :iterations)

if iterations do
  strategies = Compete.Experiment.base_strategies()
    |> Map.to_list
    |> Compete.Experiment.spice_up(2)
    |> Enum.shuffle
  IO.inspect(Compete.Experiment.run_generation(strategies, String.to_integer(iterations)))
else
  Compete.Experiment.run_one_empty(map)
end
