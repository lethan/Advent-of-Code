defmodule AOC2015.Day3 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.graphemes()
  end

  defp visit_houses(list, visisted \\ %{{0, 0} => true}, coord \\ {0, 0})
  defp visit_houses([], visisted, _coord), do: visisted

  defp visit_houses([">" | rest], visisted, {x, y}) do
    visisted = Map.put(visisted, {x + 1, y}, true)
    visit_houses(rest, visisted, {x + 1, y})
  end

  defp visit_houses(["<" | rest], visisted, {x, y}) do
    visisted = Map.put(visisted, {x - 1, y}, true)
    visit_houses(rest, visisted, {x - 1, y})
  end

  defp visit_houses(["^" | rest], visisted, {x, y}) do
    visisted = Map.put(visisted, {x, y + 1}, true)
    visit_houses(rest, visisted, {x, y + 1})
  end

  defp visit_houses(["v" | rest], visisted, {x, y}) do
    visisted = Map.put(visisted, {x, y - 1}, true)
    visit_houses(rest, visisted, {x, y - 1})
  end

  def task1(input) do
    input
    |> visit_houses()
    |> Enum.count()
  end

  def task2(input) do
    visited_by_santa =
      input
      |> Enum.take_every(2)
      |> visit_houses()

    input
    |> Enum.drop_every(2)
    |> visit_houses(visited_by_santa)
    |> Enum.count()
  end
end

input = AOC2015.Day3.import("input_day03.txt")

input
|> AOC2015.Day3.task1()
|> IO.puts()

input
|> AOC2015.Day3.task2()
|> IO.puts()
