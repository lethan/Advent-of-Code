defmodule AOC2022.Day4 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      [a1, a2, b1, b2] =
        Regex.run(~r/([0-9]+)-([0-9]+),([0-9]+)-([0-9]+)/, str, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)

      {
        a1..a2,
        b1..b2
      }
    end)
  end

  def task1(input) do
    input
    |> Enum.reduce(0, fn {a, b}, acc ->
      a = MapSet.new(a)
      b = MapSet.new(b)

      cond do
        MapSet.subset?(a, b) ->
          acc + 1

        MapSet.subset?(b, a) ->
          acc + 1

        true ->
          acc
      end
    end)
  end

  def task2(input) do
    input
    |> Enum.reduce(0, fn {a, b}, acc ->
      a = MapSet.new(a)
      b = MapSet.new(b)

      cond do
        MapSet.size(MapSet.intersection(a, b)) > 0 ->
          acc + 1

        true ->
          acc
      end
    end)
  end
end

input = AOC2022.Day4.import("input_day04.txt")

input
|> AOC2022.Day4.task1()
|> IO.puts()

input
|> AOC2022.Day4.task2()
|> IO.puts()
