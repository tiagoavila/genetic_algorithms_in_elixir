defmodule TetrisTest do
  use ExUnit.Case

  test "Tetris play" do
    TetrisInterface.start_link("priv/tetris.bin")

    soln = Genetic.run(Tetris, population_size: 1)

    IO.write("\n")
    IO.write("Best is #{soln}\n")
  end
end
