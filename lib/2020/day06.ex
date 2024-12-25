defmodule AoC.Year2020.Day6 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n")
    |> remove_last_empty()
    |> Enum.reduce([[]], &compiler/2)
  end

  defp remove_last_empty(list) do
    list
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 == ""))
    |> Enum.reverse()
  end

  defp compiler("", acc), do: [[] | acc]

  defp compiler(string, [first | rest]) do
    inserts =
      string
      |> String.graphemes()

    [[MapSet.new(inserts) | first] | rest]
  end

  def task1(input) do
    input
    |> Enum.map(fn list -> Enum.reduce(list, MapSet.new(), fn x, acc -> MapSet.union(acc, x) end) end)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.map(fn list ->
      Enum.reduce(list, MapSet.new(Enum.to_list(97..122) |> List.to_string() |> String.graphemes()), fn x, acc ->
        MapSet.intersection(acc, x)
      end)
    end)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sum()
  end
end

# input = AoC.Year2020.Day6.import("input/2020/input_day06.txt")

# input
# |> AoC.Year2020.Day6.task1()
# |> IO.puts()

# input
# |> AoC.Year2020.Day6.task2()
# |> IO.puts()
