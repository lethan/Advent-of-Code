defmodule AOC2022.Day25 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.graphemes()
      |> Enum.map(fn val ->
        case val do
          "-" -> -1
          "=" -> -2
          number_string -> String.to_integer(number_string)
        end
      end)
    end)
  end

  def convert_to_decimal(snafu) do
    convert_to_decimal(Enum.reverse(snafu), 1, 0)
  end

  def convert_to_decimal([], _base, total), do: total

  def convert_to_decimal([snafu_decimal | rest], base, total) do
    convert_to_decimal(rest, base * 5, total + base * snafu_decimal)
  end

  def convert_to_snafu(decimal) do
    base =
      Stream.unfold(1, fn n -> {n, n * 5} end)
      |> Enum.reduce_while(nil, fn base, _ ->
        if div(base - 1, 2) > abs(decimal) do
          {:halt, div(base, 5)}
        else
          {:cont, nil}
        end
      end)

    convert_to_snafu(decimal, base, [])
  end

  def convert_to_snafu(decimal, 1, snafu_list) do
    [decimal | snafu_list]
    |> Enum.reverse()
    |> Enum.drop_while(fn number -> number == 0 end)
    |> case do
      [] ->
        [0]

      list ->
        list
    end
    |> Enum.map(fn number ->
      case number do
        -1 -> "-"
        -2 -> "="
        number when number in 0..2 -> Integer.to_string(number)
      end
    end)
    |> Enum.join()
  end

  def convert_to_snafu(decimal, base, snafu_list) do
    snafu_decimal =
      2..-2//-1
      |> Enum.reduce_while(nil, fn snafu_decimal, _ ->
        case abs(decimal - snafu_decimal * base) <= div(base - 1, 2) do
          true ->
            {:halt, snafu_decimal}

          _ ->
            {:cont, nil}
        end
      end)

    convert_to_snafu(decimal - snafu_decimal * base, div(base, 5), [snafu_decimal | snafu_list])
  end

  def task1(input) do
    input
    |> Enum.reduce(0, fn snafu, sum ->
      sum + convert_to_decimal(snafu)
    end)
    |> convert_to_snafu()
  end
end

input = AOC2022.Day25.import("input_day25.txt")

input
|> AOC2022.Day25.task1()
|> IO.puts()
