defmodule Genetic.Application do
	use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Utilities.Statistics, []},
      {Utilities.Genealogy, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Genetic.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
