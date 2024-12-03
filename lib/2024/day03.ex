defmodule AoC.Year2024.Day3 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
  end

  defp multiplications(string) do
    Regex.scan(~r/mul\(([0-9]+),([0-9]+)\)/, string)
    |> Enum.map(fn [_, a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
  end

  defp controlled_multiplications(string) do
    Regex.scan(~r/mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)/, string)
    |> Enum.reduce({0, true}, fn [head | rest], {total, active} ->
      case {head, active} do
        {"do()", _} ->
          {total, true}

        {"don't()", _} ->
          {total, false}

        {_, false} ->
          {total, active}

        {_, true} ->
          [a, b] = rest
          {total + String.to_integer(a) * String.to_integer(b), active}
      end
    end)
    |> elem(0)
  end

  def task1(input) do
    input
    |> multiplications()
  end

  def task2(input) do
    input
    |> controlled_multiplications()
  end
end

# input = AoC.Year2024.Day3.import("input/2024/input_day03.txt")

# input
# |> AoC.Year2024.Day3.task1()
# |> IO.puts()

# input
# |> AoC.Year2024.Day3.task2()
# |> IO.puts()
