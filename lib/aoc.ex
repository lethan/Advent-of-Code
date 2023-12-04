defmodule AOC do
  @moduledoc """
  Documentation for `AOC`.
  """

  def runner(year, day, part) do
    apply(
      String.to_existing_atom("Elixir.AOC.Year#{year}.Day#{day}"),
      String.to_existing_atom("task#{part}"),
      []
    )
  end
end
