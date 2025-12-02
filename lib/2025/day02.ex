defmodule AoC.Year2025.Day2 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(fn str ->
      [first, last] =
        str
        |> String.split("-")

      {String.to_integer(first), String.to_integer(last)}
    end)
  end

  defp invalid_ids({first, last}, repeats) do
    digits = Integer.digits(first)
    num_digits = digits |> length()

    last_digits = Integer.digits(last) |> length()

    Enum.reduce(repeats.(last_digits), [], fn repeats, acc ->
      result =
        case rem(num_digits, repeats) do
          0 ->
            number_digits =
              num_digits
              |> div(repeats)

            digits
            |> Enum.take(number_digits)
            |> Integer.undigits()

          _ ->
            number_digits =
              (num_digits + repeats - 1)
              |> div(repeats)

            Integer.pow(10, number_digits - 1)
        end
        |> Stream.iterate(&(&1 + 1))
        |> Enum.reduce_while([], fn val, acc2 ->
          value =
            val
            |> Integer.digits()
            |> List.duplicate(repeats)
            |> List.flatten()
            |> Integer.undigits()

          acc2 = if value >= first and value <= last, do: [value | acc2], else: acc2

          if value > last, do: {:halt, acc2}, else: {:cont, acc2}
        end)
        |> Enum.reverse()

      [result | acc]
    end)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp all_invalid_ids(list, repeats \\ fn _ -> [2] end) do
    list
    |> Enum.map(&invalid_ids(&1, repeats))
    |> List.flatten()
  end

  def task1(input) do
    input
    |> all_invalid_ids()
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> all_invalid_ids(&(2..&1//1))
    |> Enum.sum()
  end
end

# input = AoC.Year2025.Day2.import("input/2025/input_day02.txt")

# input
# |> AoC.Year2025.Day2.task1()
# |> IO.puts()

# input
# |> AoC.Year2025.Day2.task2()
# |> IO.puts()
