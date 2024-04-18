defmodule Speller do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = Stream.repeatedly(fn -> Enum.random(?a..?z) end) |> Enum.take(34)
    %Chromosome{genes: genes, size: 34}
  end

  @impl true
  def fitness_function(%Chromosome{genes: genes}) do
    target = "supercalifragilisticexpialidocious"
    guess = List.to_string(genes)
    String.jaro_distance(target, guess)
  end

  @doc """
  Because String.jaro_distance/ 2 only returns 1 when the words are the same,
  you can implement your termination criteria to check if fitness equals to 1
  """
  @impl true
  def terminate?([best | _]), do: best.fitness == 1
end

soln = Genetic.run(Speller)
IO.write("\n")
IO.inspect(soln)
