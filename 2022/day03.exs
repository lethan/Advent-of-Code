defmodule AOC2022.Day3 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.graphemes()
    end)
  end

  def common(list_a, list_b) do
    set_a = MapSet.new(list_a)

    list_b
    |> MapSet.new()
    |> MapSet.intersection(set_a)
    |> MapSet.to_list()
  end

  defp priority(<<value::utf8>>) when value in ?a..?z, do: value - ?a + 1
  defp priority(<<value::utf8>>) when value in ?A..?Z, do: value - ?A + 27

  def task1(input) do
    input
    |> Enum.reduce(0, fn chars, acc ->
      length = Enum.count(chars)
      {a, b} = Enum.split(chars, div(length, 2))

      [value] = common(a, b)

      value
      |> priority
      |> Kernel.+(acc)
    end)
  end

  def task2(input) do
    input
    |> Enum.chunk_every(3)
    |> Enum.reduce(0, fn chunks, acc ->
      [a, b, c] = chunks

      [value] =
        a
        |> common(b)
        |> common(c)

      value
      |> priority
      |> Kernel.+(acc)
    end)
  end
end

input = AOC2022.Day3.import("input_day03.txt")

input
|> AOC2022.Day3.task1()
|> IO.puts()

input
|> AOC2022.Day3.task2()
|> IO.puts()
