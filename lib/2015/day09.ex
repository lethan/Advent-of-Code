defmodule AoC.Year2015.Day9 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_data()
  end

  defp convert_to_data(input) do
    input
    |> Enum.reduce(%{}, fn x, acc ->
      [a, _, b, _, distance] = String.split(x, " ")
      a = String.to_atom(a)
      b = String.to_atom(b)
      distance = String.to_integer(distance)

      Map.update(acc, a, %{b => distance}, fn value ->
        Map.put(value, b, distance)
      end)
      |> Map.update(b, %{a => distance}, fn value ->
        Map.put(value, a, distance)
      end)
    end)
  end

  defp min_max(current, min, max) do
    min =
      cond do
        is_nil(min) ->
          current

        current < min ->
          current

        true ->
          min
      end

    max =
      cond do
        is_nil(max) ->
          current

        current > max ->
          current

        true ->
          max
      end

    {min, max}
  end

  defp min_max_path(map) do
    Map.keys(map)
    |> Enum.reduce({nil, nil}, fn start, {min, max} ->
      {a, b} = min_max_path(start, 0, MapSet.new(), map, nil, nil)

      min =
        case min do
          nil ->
            a

          _ ->
            if a < min, do: a, else: min
        end

      max =
        case max do
          nil ->
            b

          _ ->
            if b > max, do: b, else: max
        end

      {min, max}
    end)
  end

  defp min_max_path(current_position, current_distance, visited, map, current_min, current_max) do
    visited = MapSet.put(visited, current_position)

    not_visited =
      MapSet.new(Map.keys(map[current_position]))
      |> MapSet.difference(visited)

    case MapSet.size(not_visited) do
      0 ->
        min_max(current_distance, current_min, current_max)

      _ ->
        not_visited
        |> Enum.reduce({current_min, current_max}, fn destination, {min, max} ->
          min_max_path(
            destination,
            current_distance + map[current_position][destination],
            visited,
            map,
            min,
            max
          )
        end)
    end
  end

  def task1(input) do
    input
    |> min_max_path()
    |> elem(0)
  end

  def task2(input) do
    input
    |> min_max_path()
    |> elem(1)
  end
end

# input = AoC.Year2015.Day9.import("input/2015/input_day09.txt")

# input
# |> AoC.Year2015.Day9.task1()
# |> IO.puts()

# input
# |> AoC.Year2015.Day9.task2()
# |> IO.puts()
