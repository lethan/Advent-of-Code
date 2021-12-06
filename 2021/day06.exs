defmodule Day6 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> convert_to_laternfish()
  end

  defp convert_to_laternfish(list) do
    freq =
      list
      |> Enum.frequencies()

    Map.new(0..8, &{&1, 0})
    |> Map.merge(freq)
  end

  defp calculate_efter_days(0, lanternfish), do: lanternfish

  defp calculate_efter_days(days, %{
         0 => zero,
         1 => one,
         2 => two,
         3 => three,
         4 => four,
         5 => five,
         6 => six,
         7 => seven,
         8 => eight
       }) do
    calculate_efter_days(days - 1, %{
      0 => one,
      1 => two,
      2 => three,
      3 => four,
      4 => five,
      5 => six,
      6 => seven + zero,
      7 => eight,
      8 => zero
    })
  end

  def task1(input) do
    calculate_efter_days(80, input)
    |> Enum.map(fn {_key, value} -> value end)
    |> Enum.sum()
  end

  def task2(input) do
    calculate_efter_days(256, input)
    |> Enum.map(fn {_key, value} -> value end)
    |> Enum.sum()
  end
end

input = Day6.import("input_day06.txt")

input
|> Day6.task1()
|> IO.puts()

input
|> Day6.task2()
|> IO.puts()
