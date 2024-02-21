defmodule AoC.Year2015.Day1 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.graphemes()
  end

  defp end_floor(list), do: end_floor(list, 0)
  defp end_floor([], current_floor), do: current_floor

  defp end_floor(["(" | rest], current_floor) do
    end_floor(rest, current_floor + 1)
  end

  defp end_floor([")" | rest], current_floor) do
    end_floor(rest, current_floor - 1)
  end

  defp find_floor(list, find), do: find_floor(list, find, 0, 0)
  defp find_floor(_list, find, current_floor, step) when find == current_floor, do: step

  defp find_floor(["(" | rest], find, current_floor, step) do
    find_floor(rest, find, current_floor + 1, step + 1)
  end

  defp find_floor([")" | rest], find, current_floor, step) do
    find_floor(rest, find, current_floor - 1, step + 1)
  end

  defp find_floor([], _find, _current_floor, _step), do: raise("Unable to find floor")

  def task1(input) do
    end_floor(input)
  end

  def task2(input) do
    find_floor(input, -1)
  end
end

# input = AoC.Year2015.Day1.import("input/2015/input_day01.txt")

# input
# |> AoC.Year2015.Day1.task1()
# |> IO.puts()

# input
# |> AoC.Year2015.Day1.task2()
# |> IO.puts()
