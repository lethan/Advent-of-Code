defmodule AOC2022.Day1 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
    end)
  end

  def task1(input) do
    input
    |> Enum.max()
  end

  def task2(input) do
    input
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(3)
    |> Enum.sum()
  end
end

input = AOC2022.Day1.import("input_day01.txt")

input
|> AOC2022.Day1.task1()
|> IO.puts()

input
|> AOC2022.Day1.task2()
|> IO.puts()
