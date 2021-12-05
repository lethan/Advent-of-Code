defmodule Day5 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&convert_to_data/1)
  end

  defp convert_to_data(string) do
    [x1, y1, x2, y2] =
      Regex.run(~r/([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)/, string, capture: :all_but_first)

    %{
      x1: String.to_integer(x1),
      y1: String.to_integer(y1),
      x2: String.to_integer(x2),
      y2: String.to_integer(y2)
    }
  end

  defp simple_map(list, map \\ %{})
  defp simple_map([], map), do: map

  defp simple_map([%{x1: x1, y1: y1, x2: x2, y2: y2} | tail], map) when x1 == x2 or y1 == y2 do
    map =
      cond do
        x1 == x2 ->
          Enum.reduce(y1..y2, map, fn y, acc ->
            Map.update(acc, {x1, y}, 1, fn value -> value + 1 end)
          end)

        y1 == y2 ->
          Enum.reduce(x1..x2, map, fn x, acc ->
            Map.update(acc, {x, y1}, 1, fn value -> value + 1 end)
          end)
      end

    simple_map(tail, map)
  end

  defp simple_map([_ | tail], map) do
    simple_map(tail, map)
  end

  defp diagonal_map([], map), do: map

  defp diagonal_map([%{x1: x1, y1: y1, x2: x2, y2: y2} | tail], map) when x1 != x2 and y1 != y2 do
    map =
      cond do
        (x1 < x2 && y1 < y2) || (x1 > x2 && y1 > y2) ->
          Enum.reduce((x1 - x1)..(x2 - x1), map, fn count, acc ->
            Map.update(acc, {x1 + count, y1 + count}, 1, fn value -> value + 1 end)
          end)

        (x1 < x2 && y1 > y2) || (x1 > x2 && y1 < y2) ->
          Enum.reduce((x1 - x1)..(x2 - x1), map, fn count, acc ->
            Map.update(acc, {x1 + count, y1 - count}, 1, fn value -> value + 1 end)
          end)
      end

    diagonal_map(tail, map)
  end

  defp diagonal_map([_ | tail], map) do
    diagonal_map(tail, map)
  end

  def task1(list) do
    list
    |> simple_map()
    |> Enum.filter(fn {_coord, value} ->
      value >= 2
    end)
    |> Enum.count()
  end

  def task2(list) do
    map =
      list
      |> simple_map()

    diagonal_map(list, map)
    |> Enum.filter(fn {_coord, value} ->
      value >= 2
    end)
    |> Enum.count()
  end
end

input = Day5.import("input_day05.txt")

input
|> Day5.task1()
|> IO.puts()

input
|> Day5.task2()
|> IO.puts()
