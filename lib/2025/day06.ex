defmodule AoC.Year2025.Day6 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn str, acc ->
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.chunk_by(fn {char, _} -> char != " " end)
      |> Enum.filter(fn [{val, _} | _] -> val != " " end)
      |> Enum.map(fn list ->
        list
        |> Enum.reduce(fn {char, _}, {str, index} ->
          {str <> char, index}
        end)
      end)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {{value, column}, index}, acc ->
        case value do
          "+" ->
            Map.update(acc, index, {:plus, []}, fn x -> {:addition, Enum.reverse(x)} end)

          "*" ->
            Map.update(acc, index, {:plus, []}, fn x -> {:multiplication, Enum.reverse(x)} end)

          _ ->
            value = String.to_integer(value)
            Map.update(acc, index, [{value, column}], fn x -> [{value, column} | x] end)
        end
      end)
    end)
  end

  defp calculate_value(map) do
    map
    |> Enum.reduce(0, fn {_, {op, list}}, acc ->
      acc +
        case op do
          :addition ->
            list
            |> Enum.map(&elem(&1, 0))
            |> Enum.sum()

          :multiplication ->
            list
            |> Enum.map(&elem(&1, 0))
            |> Enum.reduce(1, fn value, acc -> value * acc end)
        end
    end)
  end

  defp convert_to_right_hand(map) do
    map
    |> Enum.map(fn {index, {op, list}} ->
      new_list =
        list
        |> Enum.reduce(%{}, fn {value, column}, acc ->
          value
          |> Integer.digits()
          |> Enum.reduce({column, acc}, fn digit, {column, acc} ->
            acc = Map.update(acc, column, [digit], fn x -> [digit | x] end)
            {column + 1, acc}
          end)
          |> elem(1)
        end)
        |> Enum.map(fn {key, list} -> {Enum.reverse(list) |> Integer.undigits(), key} end)

      {index, {op, new_list}}
    end)
    |> Enum.into(%{})
  end

  def task1(input) do
    input
    |> calculate_value()
  end

  def task2(input) do
    input
    |> convert_to_right_hand()
    |> calculate_value()
  end
end

# input = AoC.Year2025.Day6.import("input/2025/input_day06.txt")

# input
# |> AoC.Year2025.Day6.task1()
# |> IO.puts()

# input
# |> AoC.Year2025.Day6.task2()
# |> IO.puts()
