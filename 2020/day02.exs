defmodule Day2 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&split_to_map/1)
  end

  defp split_to_map(string) do
    [min, max, letter, string] = Regex.run(~r/(?<min>[0-9]+)-(?<max>[0-9]+) (?<letter>.): (?<str>.+)/, string, capture: :all_but_first)
    %{min: String.to_integer(min), max: String.to_integer(max), letter: letter, string: string}
  end

  def task1(input) do
    input
    |> Enum.filter(fn mp ->
      count = mp.string |> String.graphemes |> Enum.count(& &1 == mp.letter)
      count <= mp.max and count >= mp.min
    end)
    |> Enum.count
  end

  def task2(input) do
    input
    |> Enum.filter(fn mp ->
      first = String.at(mp.string, mp.min - 1) == mp.letter
      last = String.at(mp.string, mp.max - 1) == mp.letter
      (first and !last) or (!first and last)
    end)
    |> Enum.count
  end
end

input = Day2.import("input_day02.txt")

input
|> Day2.task1
|> IO.puts

input
|> Day2.task2
|> IO.puts
