defmodule AOC2015.Day3 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.graphemes()
  end

  defp visit_houses(list, coords \\ [{0, 0}], visisted \\ %{{0, 0} => true}, counter \\ 0)
  defp visit_houses([], _coords, visisted, _counter), do: visisted

  defp visit_houses([">" | rest], coords, visisted, counter) do
    {x, y} = Enum.at(coords, rem(counter, Enum.count(coords)))
    new_coord = {x + 1, y}
    visisted = Map.put(visisted, new_coord, true)
    coords = List.replace_at(coords, rem(counter, Enum.count(coords)), new_coord)
    visit_houses(rest, coords, visisted, counter + 1)
  end

  defp visit_houses(["<" | rest], coords, visisted, counter) do
    {x, y} = Enum.at(coords, rem(counter, Enum.count(coords)))
    new_coord = {x - 1, y}
    visisted = Map.put(visisted, new_coord, true)
    coords = List.replace_at(coords, rem(counter, Enum.count(coords)), new_coord)
    visit_houses(rest, coords, visisted, counter + 1)
  end

  defp visit_houses(["^" | rest], coords, visisted, counter) do
    {x, y} = Enum.at(coords, rem(counter, Enum.count(coords)))
    new_coord = {x, y + 1}
    visisted = Map.put(visisted, new_coord, true)
    coords = List.replace_at(coords, rem(counter, Enum.count(coords)), new_coord)
    visit_houses(rest, coords, visisted, counter + 1)
  end

  defp visit_houses(["v" | rest], coords, visisted, counter) do
    {x, y} = Enum.at(coords, rem(counter, Enum.count(coords)))
    new_coord = {x, y - 1}
    visisted = Map.put(visisted, new_coord, true)
    coords = List.replace_at(coords, rem(counter, Enum.count(coords)), new_coord)
    visit_houses(rest, coords, visisted, counter + 1)
  end

  def task1(input) do
    input
    |> visit_houses()
    |> Enum.count()
  end

  def task2(input) do
    input
    |> visit_houses([{0, 0}, {0, 0}])
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
