defmodule Day16 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_data
  end

  defp convert_to_data(input) do
    input
    |> Enum.reduce({%{}, nil, []}, fn string, {possible_ranges, my_ticket, other_tickets} = acc ->
      cond do
        String.match?(string, ~r/([^:]+): [0-9]+-[0-9]+ or [0-9]+-[0-9]+/) ->
          [key, min1, max1, min2, max2] = Regex.run(~r/([^:]+): ([0-9]+)-([0-9]+) or ([0-9]+)-([0-9]+)/, string, capture: :all_but_first)
          {Map.put(possible_ranges, key, {String.to_integer(min1)..String.to_integer(max1), String.to_integer(min2)..String.to_integer(max2)}), my_ticket, other_tickets}
        String.match?(string, ~r/^[0-9]+(,[0-9]+)+$/) ->
          ticket_values = String.split(string, ",")
          |> Enum.map(&String.to_integer/1)
          if my_ticket == nil do
            {possible_ranges, ticket_values, other_tickets}
          else
            {possible_ranges, my_ticket, [ticket_values | other_tickets]}
          end
        true ->
          acc
      end
    end)
  end

  defp invalid_value?([], _), do: true
  defp invalid_value?([range | rest], value) do
    if value in range do
      false
    else
      invalid_value?(rest, value)
    end
  end

  defp invalid_values(tickets, ranges) do
    tickets
    |> List.flatten
    |> Enum.filter(&invalid_value?(ranges, &1))
  end

  defp reduce_valid_keys([], _, _), do: []
  defp reduce_valid_keys([valid_keys | other_keys], [value | rest_values], possible_ranges) do
    new_valid_keys = valid_keys
    |> Enum.reduce(valid_keys, fn key, acc ->
      Map.get(possible_ranges, key)
      |> Tuple.to_list
      |> invalid_value?(value)
      |> if do
        MapSet.delete(acc, key)
      else
        acc
      end
    end)

    [new_valid_keys | reduce_valid_keys(other_keys, rest_values, possible_ranges)]
  end

  defp find_field_postions([], positions), do: positions
  defp find_field_postions(valid_ranges, positions) do
    found = valid_ranges
    |> Enum.find(fn {value, _} ->
      MapSet.size(value) == 1
    end)

    if found do
      {field, index} = found
      field = field
      |> MapSet.to_list
      |> hd

      Enum.map(valid_ranges, fn {value, tmp_index} ->
        {MapSet.delete(value, field), tmp_index}
      end)
      |> Enum.reject(fn {value, _} -> MapSet.size(value)==0 end)
      |> find_field_postions(Map.put(positions, field, index))
    else
      :error
    end
  end

  def task1(input) do
    {possible_ranges, _, nearby_tickets} = input

    ranges = possible_ranges
    |> Enum.reduce([], fn {_, {range1, range2}}, acc -> [range1 | [range2 | acc]] end)

    invalid_values(nearby_tickets, ranges)
    |> Enum.sum
  end

  def task2(input) do
    {possible_ranges, my_ticket, nearby_tickets} = input

    all_ranges = possible_ranges
    |> Enum.reduce([], fn {_, {range1, range2}}, acc -> [range1 | [range2 | acc]] end)

    nearby_tickets = Enum.reject(nearby_tickets, fn ticket -> Enum.any?(ticket, fn value -> invalid_value?(all_ranges, value) end) end)

    valid_ranges = possible_ranges
    |> Map.keys
    |> MapSet.new
    |> List.duplicate(Enum.count(my_ticket))

    Enum.reduce(nearby_tickets, valid_ranges, &reduce_valid_keys(&2, &1, possible_ranges))
    |> Enum.with_index
    |> find_field_postions(%{})
    |> Enum.filter(fn {key, _} ->
      String.starts_with?(key, "departure")
    end)
    |> Enum.reduce(1, fn {_, index}, acc -> acc * Enum.at(my_ticket, index, 1) end)
  end
end

input = Day16.import("input_day16.txt")

input
|> Day16.task1
|> IO.puts

input
|> Day16.task2
|> IO.puts
