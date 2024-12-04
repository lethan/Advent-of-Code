defmodule AoC.Year2024.Day4 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {str, row}, acc ->
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {value, column}, acc ->
        Map.put(acc, {column, row}, value)
      end)
    end)
  end

  defp locate(_, _, [], _), do: true

  defp locate({x, y} = coord, {dir_x, dir_y} = direction, [current | rest], map) do
    if Map.get(map, coord) == current do
      locate({x + dir_x, y + dir_y}, direction, rest, map)
    else
      false
    end
  end

  defp xmases(map) do
    map
    |> Enum.filter(fn {_, value} -> value == "X" end)
    |> Enum.reduce(0, fn {coord, _}, acc ->
      for(x <- -1..1, y <- -1..1, x != 0 or y != 0, do: {x, y})
      |> Enum.count(fn direction ->
        locate(coord, direction, ["X", "M", "A", "S"], map)
      end)
      |> Kernel.+(acc)
    end)
  end

  defp cross_mases(map) do
    map
    |> Enum.filter(fn {_, value} -> value == "A" end)
    |> Enum.reduce(0, fn {coord, _}, acc ->
      for(x <- [-1, 1], y <- [-1, 1], do: {{{x, x}, {-x, -x}}, {{y, -y}, {-y, y}}})
      |> Enum.count(fn {{dir1, dir2}, {dir3, dir4}} ->
        locate(coord, dir1, ["A", "S"], map) && locate(coord, dir2, ["A", "M"], map) && locate(coord, dir3, ["A", "S"], map) &&
          locate(coord, dir4, ["A", "M"], map)
      end)
      |> Kernel.+(acc)
    end)
  end

  def task1(input) do
    input
    |> xmases()
  end

  def task2(input) do
    input
    |> cross_mases()
  end
end

# input = AoC.Year2024.Day4.import("input/2024/input_day04.txt")

# input
# |> AoC.Year2024.Day4.task1()
# |> IO.puts()

# input
# |> AoC.Year2024.Day4.task2()
# |> IO.puts()
