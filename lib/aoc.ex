defmodule AoC do
  @moduledoc """
  Documentation for `AoC`.
  """

  def runner(year, day, part) do
    apply(
      String.to_existing_atom("Elixir.AoC.Year#{year}.Day#{day}"),
      String.to_existing_atom("task#{part}"),
      []
    )
  end
end
