defmodule AOC2015.Day2 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&convert_to_data/1)
  end

  defp convert_to_data(input) do
    input
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
    |> List.to_tuple()
  end

  defp needed_paper({a, b, c}) do
    3 * a * b + 2 * a * c + 2 * b * c
  end

  defp needed_ribbon({a, b, c}) do
    2 * a + 2 * b + a * b * c
  end

  def task1(input) do
    input
    |> Enum.map(&needed_paper/1)
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.map(&needed_ribbon/1)
    |> Enum.sum()
  end
end

input = AOC2015.Day2.import("input_day02.txt")

input
|> AOC2015.Day2.task1()
|> IO.puts()

input
|> AOC2015.Day2.task2()
|> IO.puts()
