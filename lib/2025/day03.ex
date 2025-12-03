defmodule AoC.Year2025.Day3 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp joltage(list, len \\ 2) do
    list
    |> Enum.reduce([], fn val, acc ->
      acc = acc ++ [val]

      if length(acc) > len do
        remove_pair(acc)
        |> Enum.take(len)
      else
        acc
      end
    end)
    |> Integer.undigits()
  end

  defp remove_pair(list, acc \\ [])
  defp remove_pair([], acc), do: Enum.reverse(acc)
  defp remove_pair([a, b | rest], acc) when b > a, do: Enum.reverse(acc) ++ [b | rest]
  defp remove_pair([a | rest], acc), do: remove_pair(rest, [a | acc])

  def task1(input) do
    input
    |> Enum.map(&joltage/1)
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.map(&joltage(&1, 12))
    |> Enum.sum()
  end
end

# input = AoC.Year2025.Day3.import("input/2025/input_day03.txt")

# input
# |> AoC.Year2025.Day3.task1()
# |> IO.puts()

# input
# |> AoC.Year2025.Day3.task2()
# |> IO.puts()
