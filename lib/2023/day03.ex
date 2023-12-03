defmodule AOC.Year2023.Day3 do
  def import(file) do
    content = File.read!(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{}, %{}, 0}, fn str, {map, values, row} ->

      {map, values, row + 1}
    end)
  end

  def task1(input) do
    input
  end

  def task2(input) do
    input
  end
end

input = AOC.Year2023.Day3.import("input/2023/input_day03.txt")

input
|> AOC.Year2023.Day3.task1()
# |> IO.puts()

# input
# |> AOC.Year2023.Day3.task2()
# |> IO.puts()
