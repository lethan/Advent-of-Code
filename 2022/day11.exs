defmodule AOC2022.Day11 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
  end

  def task1(input) do
    input
    nil
  end

  def task2(input) do
    input
    nil
  end
end

input = AOC2022.Day11.import("input_day11.txt")

input
|> AOC2022.Day11.task1()
|> IO.puts()

input
|> AOC2022.Day11.task2()
|> IO.puts()
