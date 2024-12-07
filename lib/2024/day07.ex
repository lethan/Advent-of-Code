defmodule AoC.Year2024.Day7 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      [result, numbers] =
        str
        |> String.split(": ")

      result = String.to_integer(result)

      numbers =
        numbers
        |> String.split(" ")
        |> Enum.map(&String.to_integer/1)

      {result, numbers}
    end)
  end

  defp possible_target(numbers, target, operators \\ [&Kernel.+/2, &Kernel.*/2])
  defp possible_target([], _, _), do: false
  defp possible_target([target], target, _), do: true
  defp possible_target([_a], _target, _), do: false

  defp possible_target([a, b | rest], target, operators) do
    Enum.any?(operators, fn op ->
      possible_target([op.(a, b) | rest], target, operators)
    end)
  end

  defp concat(a, b), do: String.to_integer("#{a}#{b}")

  def task1(input) do
    input
    |> Enum.reduce(0, fn {result, numbers}, acc ->
      if possible_target(numbers, result), do: acc + result, else: acc
    end)
  end

  def task2(input) do
    input
    |> Enum.reduce(0, fn {result, numbers}, acc ->
      if possible_target(numbers, result, [&Kernel.+/2, &Kernel.*/2, &concat/2]), do: acc + result, else: acc
    end)
  end
end

# input = AoC.Year2024.Day7.import("input/2024/input_day07.txt")

# input
# |> AoC.Year2024.Day7.task1()
# |> IO.puts()

# input
# |> AoC.Year2024.Day7.task2()
# |> IO.puts()
