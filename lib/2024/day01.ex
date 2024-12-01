defmodule AoC.Year2024.Day1 do
  def import(file) do
    {:ok, content} = File.read(file)

    {a, b} = content
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], []}, fn str, {front, back} ->
      [a, b] = str
      |> String.split()
      |> Enum.map(&String.to_integer/1)

      {[a | front], [b | back]}
    end)

    {Enum.reverse(a), Enum.reverse(b)}
  end

  defp total_distance({a, b}) do
    a = Enum.sort(a)
    b = Enum.sort(b)

    Enum.zip(a, b)
    |> Enum.reduce(0, fn {a, b}, acc -> acc + abs(a - b) end)
  end

  defp similarity_score({a, b}) do
    a = Enum.frequencies(a)
    b = Enum.frequencies(b)

    Enum.reduce(a, 0, fn {key, value}, acc -> acc + key * value * Map.get(b, key, 0) end)
  end

  def task1(input) do
    input
    |> total_distance()
  end

  def task2(input) do
    input
    |> similarity_score()
  end
end

# input = AoC.Year2024.Day1.import("input/2024/input_day01.txt")

# input
# |> AoC.Year2024.Day1.task1()
# |> IO.puts()

# input
# |> AoC.Year2024.Day1.task2()
# |> IO.puts()
