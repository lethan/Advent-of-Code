defmodule AoC.Year2015.Day3 do
  alias AoC.Zipper

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.graphemes()
  end

  defp visit_houses(list, coords \\ Zipper.new([{0, 0}]), visited \\ %{{0, 0} => true})
  defp visit_houses([], _cords, visted), do: visted

  defp visit_houses([">" | rest], coords, visited) do
    {{x, y}, coords} = Zipper.dequeue(coords)
    new_coord = {x + 1, y}
    visited = Map.put(visited, new_coord, true)
    coords = Zipper.enqueue(coords, new_coord)
    visit_houses(rest, coords, visited)
  end

  defp visit_houses(["<" | rest], coords, visited) do
    {{x, y}, coords} = Zipper.dequeue(coords)
    new_coord = {x - 1, y}
    visited = Map.put(visited, new_coord, true)
    coords = Zipper.enqueue(coords, new_coord)
    visit_houses(rest, coords, visited)
  end

  defp visit_houses(["^" | rest], coords, visited) do
    {{x, y}, coords} = Zipper.dequeue(coords)
    new_coord = {x, y + 1}
    visited = Map.put(visited, new_coord, true)
    coords = Zipper.enqueue(coords, new_coord)
    visit_houses(rest, coords, visited)
  end

  defp visit_houses(["v" | rest], coords, visited) do
    {{x, y}, coords} = Zipper.dequeue(coords)
    new_coord = {x, y - 1}
    visited = Map.put(visited, new_coord, true)
    coords = Zipper.enqueue(coords, new_coord)
    visit_houses(rest, coords, visited)
  end

  def task1(input) do
    input
    |> visit_houses()
    |> Enum.count()
  end

  def task2(input) do
    input
    |> visit_houses(Zipper.new([{0, 0}, {0, 0}]))
    |> Enum.count()
  end
end

# input = AoC.Year2015.Day3.import("input/2015/input_day03.txt")

# input
# |> AoC.Year2015.Day3.task1()
# |> IO.puts()

# input
# |> AoC.Year2015.Day3.task2()
# |> IO.puts()
