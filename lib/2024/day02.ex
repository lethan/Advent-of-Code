defmodule AoC.Year2024.Day2 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp safe?(list) do
    [first | rest] = list

    Enum.reduce_while(rest, {first, nil}, fn current, {last, sign} ->
      diff = abs(last - current)
      new_sign = if diff == 0, do: 0, else: div(last - current, diff)

      case {sign, new_sign, diff} do
        {nil, sign, diff} when diff in 1..3 ->
          {:cont, {current, sign}}

        {sign, sign, diff} when diff in 1..3 ->
          {:cont, {current, sign}}

        _ ->
          {:halt, false}
      end
    end)
    |> case do
      false ->
        false

      _ ->
        true
    end
  end

  defp splitter(list, previous \\ [], results \\ [])
  defp splitter([], _, results), do: results
  defp splitter([head | rest], previous, results), do: splitter(rest, previous ++ [head], [previous ++ rest | results])

  defp damped?(list) do
    splitter(list)
    |> Enum.any?(&safe?/1)
  end

  def task1(input) do
    input
    |> Enum.map(&safe?/1)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def task2(input) do
    input
    |> Enum.map(&damped?/1)
    |> Enum.filter(& &1)
    |> Enum.count()
  end
end

# input = AoC.Year2024.Day2.import("input/2024/input_day02.txt")

# input
# |> AoC.Year2024.Day2.task1()
# |> IO.puts()

# input
# |> AoC.Year2024.Day2.task2()
# |> IO.puts()
