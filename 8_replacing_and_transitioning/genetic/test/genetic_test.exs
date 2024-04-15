defmodule GeneticTest do
  use ExUnit.Case
  doctest Genetic

  test "Test Schedule Problem" do
    soln = Genetic.run(Schedule)

    assert soln != nil
  end
end
