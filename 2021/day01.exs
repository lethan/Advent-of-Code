defmodule Day1 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def task1(list, last_value \\ nil)
  def task1([value | tail], nil), do: task1(tail, value)

  def task1([value | tail], last_value) do
    task1(tail, value) +
      if value > last_value do
        1
      else
        0
      end
  end

  def task1([], _), do: 0

  def task2(list, last_value \\ nil)
  def task2([value | tail], nil), do: task2(tail, value)

  def task2([next_value | tail = [_, value | _]], last_value) do
    task2(tail, next_value) +
      if value > last_value do
        1
      else
        0
      end
  end

  def task2(_, _), do: 0
end

input = Day1.import("input_day01.txt")

input
|> Day1.task1()
|> IO.puts()

input
|> Day1.task2()
|> IO.puts()
