defmodule Day5 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
  end

  def seat_id(boardingpass) do
    boardingpass
    |> String.graphemes
    |> Enum.map(&binary_value/1)
    |> Enum.reverse
    |> Enum.reduce({0, 1}, fn x, {value, base} -> {value + x * base, base*2} end)
    |> elem(0)
  end

  defp binary_value(letter) do
    case letter do
      "B" ->
        1
      "F" ->
        0
      "R" ->
        1
      "L" ->
        0
    end
  end

  def find_vacent([current | passes], last_value \\ nil) do
    if last_value do
      if last_value + 1 == current do
        find_vacent(passes, current)
      else
        last_value + 1
      end
    else
      find_vacent(passes, current)
    end
  end

  def task1(input) do
    input
    |> Enum.map(&seat_id/1)
    |> Enum.max
  end

  def task2(input) do
    input
    |> Enum.map(&seat_id/1)
    |> Enum.sort
    |> find_vacent
  end
end

input = Day5.import("input_day05.txt")

input
|> Day5.task1
|> IO.puts

input
|> Day5.task2
|> IO.puts
