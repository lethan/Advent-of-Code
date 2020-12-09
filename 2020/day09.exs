defmodule Day9 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp valid_number?([], _number), do: false
  defp valid_number?([a | rest], number) do
    case Enum.member?(rest, number - a) do
      true -> true
      false -> valid_number?(rest, number)
    end
  end

  defp find_invalid(preamble = [_ | pre_rest], [value | rest]) do
    if valid_number?(preamble, value) do
      find_invalid(pre_rest ++ [value], rest)
    else
      value
    end
  end

  defp encryption_weakness(data, target_sum, selected \\ [], current_sum \\ 0) do
    cond do
      current_sum == target_sum ->
        if Enum.count(selected) > 1 do
         {min, max} = Enum.min_max(selected)
         min + max
        else
          [current_number | rest_data] = data
          encryption_weakness(rest_data, target_sum, selected ++ [current_number], current_sum + current_number)
        end
      current_sum < target_sum ->
        [current_number | rest_data] = data
        encryption_weakness(rest_data, target_sum, selected ++ [current_number], current_sum + current_number)
      current_sum > target_sum ->
        [current_selected | rest_selected] = selected
        encryption_weakness(data, target_sum, rest_selected, current_sum - current_selected)
    end
  end

  def task1(input) do
    find_invalid(Enum.take(input, 25), Enum.drop(input, 25))
  end

  def task2(input, invalid_number) do
    encryption_weakness(input, invalid_number)
  end
end

input = Day9.import("input_day09.txt")

first_invalid = input
|> Day9.task1
IO.puts(first_invalid)

input
|> Day9.task2(first_invalid)
|> IO.puts
