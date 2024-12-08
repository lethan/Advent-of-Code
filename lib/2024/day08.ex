defmodule AoC.Year2024.Day8 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {str, row}, acc ->
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, column}, acc ->
        Map.put(
          acc,
          {column, row},
          case char do
            "." -> :empty
            x -> x
          end
        )
      end)
    end)
  end

  defp get_antennas(map) do
    map
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      case value do
        :empty ->
          acc

        x ->
          Map.update(acc, x, [key], fn current -> [key | current] end)
      end
    end)
  end

  defp antinotes(map, limit \\ 1..1) do
    map
    |> get_antennas()
    |> Enum.reduce(MapSet.new(), fn {_, [point | points]}, acc ->
      antinote_points(point, points, map, limit)
      |> MapSet.union(acc)
    end)
  end

  defp antinote_points(antenna, antennas, map, limit, result \\ MapSet.new())
  defp antinote_points(_, [], _, _, result), do: result

  defp antinote_points({a_x, a_y} = antenna, [{b_x, b_y} = next | rest], map, limit, result) do
    diff_x = b_x - a_x
    diff_y = b_y - a_y

    result =
      limit
      |> Enum.reduce_while(result, fn n, acc ->
        point_x = b_x + n * diff_x
        point_y = b_y + n * diff_y
        point = {point_x, point_y}

        case Map.get(map, point) do
          nil ->
            {:halt, acc}

          _ ->
            {:cont, MapSet.put(acc, point)}
        end
      end)

    result =
      limit
      |> Enum.reduce_while(result, fn n, acc ->
        point_x = a_x - n * diff_x
        point_y = a_y - n * diff_y
        point = {point_x, point_y}

        case Map.get(map, point) do
          nil ->
            {:halt, acc}

          _ ->
            {:cont, MapSet.put(acc, point)}
        end
      end)

    antinote_points(antenna, rest, map, limit, result)
    |> MapSet.union(antinote_points(next, rest, map, limit, result))
  end

  def task1(input) do
    input
    |> antinotes()
    |> Enum.count()
  end

  def task2(input) do
    input
    |> antinotes(Stream.unfold(0, fn x -> {x, x + 1} end))
    |> Enum.count()
  end
end

# input = AoC.Year2024.Day8.import("input/2024/input_day08.txt")

# input
# |> AoC.Year2024.Day8.task1()
# |> IO.puts()

# input
# |> AoC.Year2024.Day8.task2()
# |> IO.puts()
