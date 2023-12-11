defmodule AoC.Year2023.Day11 do
  def import(file) do
    content = File.read!(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {str, row}, acc ->
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {s, column}, acc ->
        if s == "#", do: Map.put(acc, {column, row}, :galaxy), else: acc
      end)
    end)
  end

  defp exspansions(map) do
    keys =
      map
      |> Map.keys()

    [&elem(&1, 0), &elem(&1, 1)]
    |> Enum.map(fn e ->
      Enum.map(keys, e)
      |> Enum.uniq()
      |> (fn x ->
            {min, max} = Enum.min_max(x)
            for(r <- min..max, r not in x, do: r)
          end).()
    end)
    |> List.to_tuple()
  end

  defp total_distance(galaxies, exspansion_size \\ 2) do
    exps = exspansions(galaxies)

    total_distance(Map.keys(galaxies), exps, exspansion_size)
  end

  defp total_distance(galaxies, expansions, exspansion_size, total \\ 0)
  defp total_distance([], _, _, total), do: total

  defp total_distance([{x, y} | galaxies], expansions, exspansion_size, total) do
    new_total =
      galaxies
      |> Enum.reduce(total, fn {n_x, n_y}, acc ->
        {a, b} = Enum.min_max([x, n_x])

        diff_x =
          b - a +
            (exspansion_size - 1) *
              (for(t <- a..b, t in elem(expansions, 0), do: t) |> Enum.count())

        {a, b} = Enum.min_max([y, n_y])

        diff_y =
          b - a +
            (exspansion_size - 1) *
              (for(t <- a..b, t in elem(expansions, 1), do: t) |> Enum.count())

        acc + diff_x + diff_y
      end)

    total_distance(galaxies, expansions, exspansion_size, new_total)
  end

  def task1(input) do
    input
    |> total_distance()
  end

  def task2(input) do
    input
    |> total_distance(1_000_000)
  end
end

# input = AoC.Year2023.Day11.import("input/2023/input_day11.txt")

# input
# |> AoC.Year2023.Day11.task1()
# |> IO.puts()

# input
# |> AoC.Year2023.Day11.task2()
# |> IO.puts()
