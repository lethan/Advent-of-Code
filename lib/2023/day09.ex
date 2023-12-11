defmodule AoC.Year2023.Day9 do
  def import(file) do
    content = File.read!(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp diff(list, result \\ [])
  defp diff([_], result), do: Enum.reverse(result)
  defp diff([a, b | rest], result), do: diff([b | rest], [b - a | result])

  defp next_value(list) do
    if Enum.all?(list, &(&1 == 0)) do
      0
    else
      List.last(list) + next_value(diff(list))
    end
  end

  def task1(input) do
    input
    |> Enum.map(&next_value/1)
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&next_value/1)
    |> Enum.sum()
  end
end

# input = AoC.Year2023.Day9.import("input/2023/input_day09.txt")

# input
# |> AoC.Year2023.Day9.task1()
# |> IO.puts()

# input
# |> AoC.Year2023.Day9.task2()
# |> IO.puts()
