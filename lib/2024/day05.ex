defmodule AoC.Year2024.Day5 do
  def import(file) do
    {:ok, content} = File.read(file)

    [rules, orders] =
      content
      |> String.split("\n\n", trim: true)

    rules =
      rules
      |> String.split("\n")
      |> Enum.reduce(%{}, fn str, acc ->
        [before, later] =
          str
          |> String.split("|")
          |> Enum.map(&String.to_integer/1)

        Map.update(acc, later, MapSet.new([before]), fn x -> MapSet.put(x, before) end)
      end)

    orders =
      orders
      |> String.split("\n", trim: true)
      |> Enum.map(fn str ->
        str
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)

    {rules, orders}
  end

  def in_order?(pages, rules) do
    pages
    |> Enum.reduce_while(MapSet.new(), fn page, acc ->
      if MapSet.member?(acc, page) do
        {:halt, false}
      else
        {:cont, MapSet.union(acc, Map.get(rules, page, MapSet.new()))}
      end
    end)
    |> case do
      false -> false
      _ -> true
    end
  end

  def task1(input) do
    {rules, updates} = input

    updates
    |> Enum.filter(fn x -> in_order?(x, rules) end)
    |> Enum.map(fn x ->
      pos =
        x
        |> length()
        |> div(2)

      Enum.at(x, pos)
    end)
    |> Enum.sum()
  end

  def task2(input) do
    {rules, updates} = input

    updates
    |> Enum.filter(fn x -> not in_order?(x, rules) end)
    |> Enum.map(fn x ->
      x
      |> Enum.sort(fn a, b -> MapSet.member?(Map.get(rules, b, MapSet.new()), a) end)
    end)
    |> Enum.map(fn x ->
      pos =
        x
        |> length()
        |> div(2)

      Enum.at(x, pos)
    end)
    |> Enum.sum()
  end
end

# input = AoC.Year2024.Day5.import("input/2024/input_day05.txt")

# input
# |> AoC.Year2024.Day5.task1()
# |> IO.puts()

# input
# |> AoC.Year2024.Day5.task2()
# |> IO.puts()
