defmodule AoC.Year2023.Day1 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.graphemes()
      |> Enum.map(fn x ->
        case Integer.parse(x) do
          {num, ""} ->
            num

          :error ->
            x
        end
      end)
    end)
  end

  defp parse_text_numbers(list, result \\ [])

  defp parse_text_numbers(["o", "n", "e" | rest], result),
    do: parse_text_numbers(["e" | rest], [1 | result])

  defp parse_text_numbers(["t", "w", "o" | rest], result),
    do: parse_text_numbers(["o" | rest], [2 | result])

  defp parse_text_numbers(["t", "h", "r", "e", "e" | rest], result),
    do: parse_text_numbers(["e" | rest], [3 | result])

  defp parse_text_numbers(["f", "o", "u", "r" | rest], result),
    do: parse_text_numbers(rest, [4 | result])

  defp parse_text_numbers(["f", "i", "v", "e" | rest], result),
    do: parse_text_numbers(["e" | rest], [5 | result])

  defp parse_text_numbers(["s", "i", "x" | rest], result),
    do: parse_text_numbers(rest, [6 | result])

  defp parse_text_numbers(["s", "e", "v", "e", "n" | rest], result),
    do: parse_text_numbers(rest, [7 | result])

  defp parse_text_numbers(["e", "i", "g", "h", "t" | rest], result),
    do: parse_text_numbers(["t" | rest], [8 | result])

  defp parse_text_numbers(["n", "i", "n", "e" | rest], result),
    do: parse_text_numbers(["e" | rest], [9 | result])

  defp parse_text_numbers([val | rest], result), do: parse_text_numbers(rest, [val | result])
  defp parse_text_numbers([], result), do: Enum.reverse(result)

  defp first_and_last(list) do
    Enum.reduce(list, {nil, nil}, fn val, {first, _last} = result ->
      case {val, first} do
        {num, nil} when is_integer(num) ->
          {num, num}

        {num, _} when is_integer(num) ->
          {first, num}

        _ ->
          result
      end
    end)
  end

  def task1(input) do
    input
    |> Enum.map(&first_and_last/1)
    |> Enum.map(fn {a, b} -> 10 * a + b end)
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.map(&parse_text_numbers/1)
    |> Enum.map(&first_and_last/1)
    |> Enum.map(fn {a, b} -> 10 * a + b end)
    |> Enum.sum()
  end
end

# input = AoC2023.Day1.import("input_day01.txt")

# input
# |> AoC2023.Day1.task1()
# |> IO.puts()

# input
# |> AoC2023.Day1.task2()
# |> IO.puts()
