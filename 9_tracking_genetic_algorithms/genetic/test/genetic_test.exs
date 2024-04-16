defmodule GeneticTest do
  use ExUnit.Case
  doctest Genetic

  # test "Test Schedule Problem" do
  #   soln = Genetic.run(Schedule)

  #   assert soln != nil
  # end

  test "Test Tiger Simulation Problem" do
    tiger =
      Genetic.run(TigerSimulation,
        population_size: 20,
        selection_rate: 0.9,
        mutation_rate: 0.1
      )

    assert tiger != nil

    {_, zero_gen_stats} = Utilities.Statistics.lookup(0)
    {_, fivehundred_gen_stats} = Utilities.Statistics.lookup(500)
    {_, onethousand_gen_stats} = Utilities.Statistics.lookup(1000)

    IO.inspect(zero_gen_stats.mean_fitness)
    IO.inspect(fivehundred_gen_stats.mean_fitness)
    IO.inspect(onethousand_gen_stats.mean_fitness)
  end
end
