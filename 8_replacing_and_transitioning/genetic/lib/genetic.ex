defmodule Genetic do
  @moduledoc """
  Defines each step of the algorithm based on the rules determined
  """

  alias Types.Chromosome
  alias Toolbox.Selection

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
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  @doc """
  Selection is responsible for matching parents that will produce strong children.

  - The selection step must take a population as input.
  - The selection step must produce a transformed population that’s easy to work with during crossover — say by
    returning a list of tuples which are pairs of parents.
  """
  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, &Selection.elite/2)
    select_rate = Keyword.get(opts, :selection_rate, 0.8)

    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n+1

    parents =
      select_fn
      |> apply([population, n])

    leftover = MapSet.difference(MapSet.new(population), MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(& List.to_tuple(&1))

    {parents, MapSet.to_list(leftover)}
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
    crossover_fn = Keyword.get(opts, :crossover_type, &Toolbox.Crossover.single_point/2)
    population
    |> Enum.reduce([],
        fn {p1, p2}, acc ->
          {c1, c2} = apply(crossover_fn, [p1, p2])
          [c1 | [c2 | acc]]
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
    mutate_fn = Keyword.get(opts, :mutation_type, &Toolbox.Mutation.scramble/1)
    rate = Keyword.get(opts, :mutation_rate, 0.05)
    n = floor(length(population) * rate)
    population
    |> Enum.take_random(n)
    |> Enum.map(& apply(mutate_fn, [&1]))
  end

  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0, opts)

    population
    |> evolve(problem, 0, opts)
  end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = hd(population)
    fit_str =
      best.fitness
      |> :erlang.float_to_binary(decimals: 4)
    IO.write("\rCurrent best: #{fit_str}\tGeneration: #{generation}")
    if problem.terminate?(population, generation) do
      best
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      mutants = mutation(population, opts)
      offspring = children ++ mutants
      new_population = reinsertion(parents, offspring, leftover, opts)
      evolve(new_population, problem, generation+1, opts)
    end
  end

  def reinsertion(parents, offspring, leftover, opts \\ []) do
    strategy = Keyword.get(opts, :reinsertion_strategy, &Toolbox.Reinsertion.pure/3)
    apply(strategy, [parents, offspring, leftover])
  end
end
