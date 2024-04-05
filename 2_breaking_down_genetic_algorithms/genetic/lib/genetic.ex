defmodule Genetic do
  @moduledoc """
  Defines each step of the algorithm based on the rules determined
  """

  @doc """
  The first step in every genetic algorithm is initializing a population. Typically, the first population is random
  The idea is to start out examining many different solutions and slowly work toward the best ones.

  - The initialization step must produce an initial population— a list of possible solutions.
  - The function which initializes the population should be agnostic to how the chromosome is encoded.
  You can achieve this by accepting a function that returns a chromosome.
  """
  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end

  @doc """
  The evaluation step is responsible for evaluating each chromosome based on some fitness function and sorting
  the population based on this fitness.

  - The evaluation step must take a population as input.
  - The evaluation step must produce a population sorted by fitness.
  - The function which evaluates the population should take a parameter that is a function that returns the
    fitness of each chromosome.
  -The fitness function can return anything, as long as the fitness can be sorted.
  """
  def evaluate(population, fitness_function, opts \\ []) do
    population
    |> Enum.sort_by(fitness_function, &>=/2)
  end

  @doc """
  Selection is responsible for matching parents that will produce strong children.

  - The selection step must take a population as input.
  - The selection step must produce a transformed population that’s easy to work with during crossover — say by
    returning a list of tuples which are pairs of parents.
  """
  def select(population, opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  @doc """
  Crossover is analogous to reproduction. It’s a genetic operator that takes two or more parent chromosomes
  and produces two or more child chromosomes.
  The goal of crossover is to exploit the strengths of current solutions to find new, better solutions.

  - Take a list of 2-tuples as input.
  - Combine the 2-tuples, which represent pairs of parents. For now, use single-point crossover.
  - Return a population identical in size to the initial population.
  """
  def crossover(population, opts \\ []) do
    population
    |> Enum.reduce([],
        fn {p1, p2}, acc ->
          cx_point = :rand.uniform(length(p1))
          {h1, t1} = Enum.split(p1, cx_point)
          {h2, t2} = Enum.split(p2, cx_point)
          [h1 ++ t2, h2 ++ t1 | acc]
        end
      )
  end

  @doc """
  Mutation is the last step before the next generation. Remember, the goal of mutation is to prevent premature
  convergence by transforming some of the chromosomes in the population.

  - The mutation step should accept a population as input.
  - The mutation step should mutate only some of the chromosomes in the population— the percentage should be
    relatively small.
  """
  def mutation(population, opts \\ []) do
    population
    |> Enum.map(
        fn chromosome ->
          if :rand.uniform() < 0.05 do
            Enum.shuffle(chromosome)
          else
            chromosome
          end
        end
      )
  end

  def run(fitness_function, genotype, max_fitness, opts \\ []) do
    population = initialize(genotype, opts)
    population
    |> evolve(fitness_function, genotype, max_fitness, opts)
  end

  def evolve(population, fitness_function, genotype, max_fitness, opts \\ []) do
    population = evaluate(population, fitness_function, opts)
    best = hd(population)
    IO.write("\rCurrent Best: #{fitness_function.(best)}")
    if fitness_function.(best) == max_fitness do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(fitness_function, genotype, max_fitness, opts)
    end
  end
end
