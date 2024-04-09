defmodule OneMax do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = Enum.map(1..42, fn _ -> Enum.random(0..1) end)
    %Chromosome{genes: genes, size: 42}
  end

  @impl true
  def fitness_function(%Chromosome{genes: genes}), do: Enum.sum(genes)

  @impl true
  def terminate?([best | _]), do: best.fitness == 42
end

soln = Genetic.run(OneMax)
IO.write("\n")
IO.inspect(soln)
