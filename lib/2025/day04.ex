defmodule AoC.Year2025.Day4 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {str, row}, acc ->
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, column}, acc2 ->
        type =
          case char do
            "." -> :empty
            "@" -> :roll
          end

        Map.put(acc2, {column, row}, type)
      end)
    end)
  end

  def accecessable_rolls(map) do
    map
    |> Enum.filter(fn {_, value} -> value == :roll end)
    |> Enum.reduce(0, fn {{x, y}, _}, acc ->
      neighbors =
        for(xs <- -1..1, ys <- -1..1, xs != 0 or ys != 0, do: {xs, ys})
        |> Enum.reduce(0, fn {test_x, test_y}, counter ->
          if(Map.get(map, {x + test_x, y + test_y}) == :roll, do: counter + 1, else: counter)
        end)

      if neighbors < 4, do: acc + 1, else: acc
    end)
  end

  defp remove_rolls(map, counter \\ 0) do
    {map, counter} =
      map
      |> Enum.filter(fn {_, value} -> value == :roll end)
      |> Enum.reduce({map, counter}, fn {{x, y}, _}, {map, counter} ->
        neighbors =
          for(xs <- -1..1, ys <- -1..1, xs != 0 or ys != 0, do: {xs, ys})
          |> Enum.reduce(0, fn {test_x, test_y}, neighbor_rolls ->
            if(Map.get(map, {x + test_x, y + test_y}) == :roll, do: neighbor_rolls + 1, else: neighbor_rolls)
          end)

        if neighbors < 4 do
          map = Map.put(map, {x, y}, :empty)
          counter = counter + 1
          {map, counter}
        else
          {map, counter}
        end
      end)

    if accecessable_rolls(map) == 0 do
      counter
    else
      remove_rolls(map, counter)
    end
  end

  def task1(input) do
    input
    |> accecessable_rolls()
  end

  def task2(input) do
    input
    |> remove_rolls()
  end
end

# input = AoC.Year2025.Day4.import("input/2025/input_day04.txt")

# input
# |> AoC.Year2025.Day4.task1()
# |> IO.puts()

# input
# |> AoC.Year2025.Day4.task2()
# |> IO.puts()
