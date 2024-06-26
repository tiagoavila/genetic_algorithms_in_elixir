defmodule Toolbox.Selection do
  def elite(population, n) do
    population
    |> Enum.take(n)
  end

  def random(population, n) do
    population
    |> Enum.take_random(n)
  end

  def tournament(population, n, tournsize) do
    0..(n-1)
    |> Enum.map(
      fn _ ->
        population
        |> Enum.take_random(tournsize)
        |> Enum.max_by(&(&1.fitness))
      end
    )
  end

  def roulette(chromosomes, n) do
    sum_fitness =
      chromosomes
      |> Enum.map(&(&1.fitness))
      |> Enum.sum()

    0..(n - 1)
    |> Enum.map(fn _ ->
      u = :rand.uniform() * sum_fitness
      chromosomes
      |> Enum.reduce_while(
        0,
        fn x, sum ->
          if x.fitness + sum > u do
            {:halt, x}
          else
            {:cont, x.fitness + sum}
          end
        end
      )
    end)
  end
end
