defmodule OneMax do
  def solution() do
    population = for _ <- 1..100, do: Enum.map(1..1000, fn _ -> Enum.random(0..1) end)

    # The evaluate function uses the Enum.sort_by/3 function to sort the population by the sum in descending order.
    # This means that better solutions will exist at the top of the population.
    # It also means that better solutions will be grouped together.
    # Sorting your population is important for the next step.
    evaluate = fn population ->
      Enum.sort_by(population, &Enum.sum/1, &>=/2)
    end

    # In this function, you use Enum.chunk_every/ 2 to create a list of pairs.
    # These pairs are parents that are selected for combination in the crossover step.
    selection = fn population ->
      population
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)
    end

    # Crossover is analogous to reproduction. It’s a genetic operator that takes two or more parent chromosomes
    # and produces two or more child chromosomes.
    # So, how are the new chromosomes created? A random crossover point is selected using Erlang’s rand module.
    # The :rand.uniform/ 1 function produces a uniform integer between 0 and N-1 where N is the integer parameter
    # it receives. Passing 1000 to this function means you’ll receive a random integer between 0 and 1000.
    # Enum.split/ 2 returns a tuple of two enumerables. The enumerables are split at the random point selected earlier.
    # The chromosomes are then recombined with the tails swapped.
    # This is known as single-point crossover and is one of the simplest crossover methods used.
    crossover = fn population ->
      Enum.reduce(population, [], fn {p1, p2}, acc ->
        cx_point = :rand.uniform(1000)
        {h1, t1} = Enum.split(p1, cx_point)
        {h2, t2} = Enum.split(p2, cx_point)
        [h1 ++ t2, h2 ++ t1 | acc]
      end)
    end

    # This function iterates over the entire population and randomly shuffles a chromosome with a probability of 5%.
    mutation = fn population ->
      population
      |> Enum.map(fn chromosome ->
        if :rand.uniform() < 0.05 do
          Enum.shuffle(chromosome)
        else
          chromosome
        end
      end)
    end

    algorithm = fn population, algorithm ->
      best = Enum.max_by(population, &Enum.sum(&1))
      IO.write("\rCurrent Best: " <> Integer.to_string(Enum.sum(best)))

      if Enum.sum(best) == 1000 do
        best
      else
        # Initial population
        population
        # Evaluate the population
        |> evaluate.()
        # Select Parents
        |> selection.()
        # Create Children
        |> crossover.()
        # Mutate the children
        |> mutation.()
        # Repeat the process with the new population
        |> algorithm.(algorithm)
      end
    end

    solution = algorithm.(population, algorithm)
    IO.write("\n Answer is \n")
    IO.inspect(solution)
  end
end

OneMax.solution()
