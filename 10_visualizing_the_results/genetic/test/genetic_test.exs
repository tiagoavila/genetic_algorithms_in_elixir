defmodule GeneticTest do
  use ExUnit.Case
  doctest Genetic

  @tag skip: true
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

    IO.puts("\n")
    IO.inspect(zero_gen_stats.mean_fitness, label: "0th")
    IO.inspect(fivehundred_gen_stats.mean_fitness, label: "500th")
    IO.inspect(onethousand_gen_stats.mean_fitness, label: "1000th")
  end

  @tag skip: true
  test "Test Tiger Simulation Problem showing average Tiger" do
    tiger =
      Genetic.run(TigerSimulation,
        population_size: 20,
        selection_rate: 0.9,
        mutation_rate: 0.1,
        statistics: %{average_tiger: &TigerSimulation.average_tiger/1}
      )

    assert tiger != nil

    {_, zero_gen_stats} = Utilities.Statistics.lookup(0)
    {_, fivehundred_gen_stats} = Utilities.Statistics.lookup(500)
    {_, onethousand_gen_stats} = Utilities.Statistics.lookup(1000)

    IO.puts("\n")
    IO.inspect(zero_gen_stats.average_tiger, label: "0th")
    IO.inspect(fivehundred_gen_stats.average_tiger, label: "500th")
    IO.inspect(onethousand_gen_stats.average_tiger, label: "1000th")
  end

  test "Test Tiger Simulation Problem showing Genealogy tree" do
    tiger =
      Genetic.run(TigerSimulation,
        population_size: 6,
        selection_rate: 0.9,
        mutation_rate: 0.1,
        statistics: %{average_tiger: &TigerSimulation.average_tiger/1}
      )

    assert tiger != nil

    genealogy = Utilities.Genealogy.get_tree()

    {:ok, dot} = Graph.Serializers.DOT.serialize(genealogy)
    {:ok, dotfile} = File.open("tiger_simulation.dot", [:write])
    :ok = IO.binwrite(dotfile, dot)
    :ok = File.close(dotfile)

    IO.inspect(Graph.vertices(genealogy), label: "Genealogy tree")
  end
end
