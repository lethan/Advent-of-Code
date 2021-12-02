defmodule Day2 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&split_to_map/1)
  end

  defp split_to_map(string) do
    [direction, distance] = String.split(string, " ")
    %{direction: direction, distance: String.to_integer(distance)}
  end

  def task1(list, position \\ %{horizontal: 0, depth: 0})

  def task1(
        [%{direction: "forward", distance: distance} | tail],
        position = %{
          horizontal: h
        }
      ) do
    task1(tail, %{position | horizontal: h + distance})
  end

  def task1([%{direction: "down", distance: distance} | tail], position = %{depth: d}) do
    task1(tail, %{position | depth: d + distance})
  end

  def task1([%{direction: "up", distance: distance} | tail], position = %{depth: d}) do
    task1(tail, %{position | depth: d - distance})
  end

  def task1([], %{horizontal: h, depth: d}), do: h * d

  def task2(list, position \\ %{horizontal: 0, depth: 0, aim: 0})

  def task2(
        [%{direction: "forward", distance: distance} | tail],
        position = %{
          horizontal: h,
          depth: d,
          aim: a
        }
      ) do
    task2(tail, %{position | horizontal: h + distance, depth: d + distance * a})
  end

  def task2(
        [%{direction: "down", distance: distance} | tail],
        position = %{aim: a}
      ) do
    task2(tail, %{position | aim: a + distance})
  end

  def task2(
        [%{direction: "up", distance: distance} | tail],
        position = %{aim: a}
      ) do
    task2(tail, %{position | aim: a - distance})
  end

  def task2([], %{horizontal: h, depth: d}), do: h * d
end

input = Day2.import("input_day02.txt")

input
|> Day2.task1()
|> IO.puts()

input
|> Day2.task2()
|> IO.puts()
