defmodule AoC.Year2020.Day18 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&convert_to_data/1)
  end

  defp convert_to_data(string), do: convert_to_data(string, 0, "")

  defp convert_to_data("", 0, _), do: []
  defp convert_to_data(" " <> rest, 0, _), do: convert_to_data(rest, 0, "")
  defp convert_to_data("+" <> rest, 0, _), do: [:plus | convert_to_data(rest, 0, "")]
  defp convert_to_data("*" <> rest, 0, _), do: [:multiply | convert_to_data(rest, 0, "")]
  defp convert_to_data("(" <> rest, 0, _), do: convert_to_data(rest, 1, "")
  defp convert_to_data("(" <> rest, depth, acc), do: convert_to_data(rest, depth + 1, acc <> "(")
  defp convert_to_data(")" <> rest, 1, acc), do: [convert_to_data(acc, 0, "") | convert_to_data(rest, 0, "")]
  defp convert_to_data(")" <> rest, depth, acc), do: convert_to_data(rest, depth - 1, acc <> ")")

  defp convert_to_data(number_string, 0, _) do
    [number, rest] = Regex.run(~r/^([0-9]+)(.*)$/, number_string, capture: :all_but_first)
    [String.to_integer(number) | convert_to_data(rest, 0, "")]
  end

  defp convert_to_data(string, depth, acc) do
    {first, rest} = String.split_at(string, 1)
    convert_to_data(rest, depth, acc <> first)
  end

  defp expression_value(number) when is_integer(number), do: number
  defp expression_value([number]) when is_integer(number), do: number

  defp expression_value([first, :plus, second | rest]) do
    expression_value([expression_value(first) + expression_value(second) | rest])
  end

  defp expression_value([first, :multiply, second | rest]) do
    expression_value([expression_value(first) * expression_value(second) | rest])
  end

  defp expression_value2(list) do
    list
    |> Enum.map(fn x ->
      if is_list(x) do
        expression_value2(x)
      else
        x
      end
    end)
    |> only_addition()
    |> multiplication_value()
  end

  defp only_addition([]), do: []
  defp only_addition([number]) when is_integer(number), do: [number]
  defp only_addition([first, :plus, second | rest]), do: only_addition([first + second | rest])
  defp only_addition([first, :multiply | rest]), do: [first, :multiply | only_addition(rest)]

  defp multiplication_value(number) when is_integer(number), do: number
  defp multiplication_value([number]) when is_integer(number), do: number

  defp multiplication_value([first, :multiply, second | rest]) do
    multiplication_value([multiplication_value(first) * multiplication_value(second) | rest])
  end

  def task1(input) do
    input
    |> Enum.map(&expression_value/1)
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.map(&expression_value2/1)
    |> Enum.sum()
  end
end

# input = AoC.Year2020.Day18.import("input/2020/input_day18.txt")

# input
# |> AoC.Year2020.Day18.task1()
# |> IO.puts()

# input
# |> AoC.Year2020.Day18.task2()
# |> IO.puts()
