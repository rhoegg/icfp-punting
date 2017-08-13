Code.require_file("test/strategy/fake_strategies.ex")
ExUnit.configure(exclude: [:functional, :python, :icfp])
ExUnit.start()
