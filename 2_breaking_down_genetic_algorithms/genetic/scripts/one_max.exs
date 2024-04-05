genotype = fn -> Enum.map(1..1_000, fn _ -> Enum.random(0..1) end) end

max_fitness = 1_000

fitness_function = fn chromosome -> Enum.sum(chromosome) end

soln = Genetic.run(fitness_function, genotype, max_fitness)

IO.write("\n")
IO.inspect(soln)
