defmodule Day9 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_data()
  end

  defp convert_to_data(input) do
    input
    |> Enum.map(fn x ->
      x
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {data, row}, acc ->
      Enum.reduce(data, acc, fn {value, column}, acc2 ->
        Map.put(acc2, {column, row}, value)
      end)
    end)
  end

  def low_points(cave_map) do
    diffs =
      for diff_x <- -1..1,
          diff_y <- -1..1,
          abs(diff_x) != abs(diff_y),
          do: {diff_x, diff_y}

    cave_map
    |> Enum.filter(fn {{x, y}, value} ->
      Enum.reduce(diffs, true, fn {diff_x, diff_y}, acc ->
        acc and value < Map.get(cave_map, {x + diff_x, y + diff_y}, 10)
      end)
    end)
  end

  def find_basin({[], []}, _cave_map, current_basin), do: current_basin

  def find_basin({[], back_queue}, cave_map, current_basin),
    do: find_basin({Enum.reverse(back_queue), []}, cave_map, current_basin)

  def find_basin({[{coord = {x, y}, value} | rest], back_queue}, cave_map, current_basin) do
    diffs =
      for diff_x <- -1..1,
          diff_y <- -1..1,
          abs(diff_x) != abs(diff_y),
          do: {diff_x, diff_y}

    if MapSet.member?(current_basin, coord) do
      find_basin({rest, back_queue}, cave_map, current_basin)
    else
      current_basin = MapSet.put(current_basin, coord)

      back_queue =
        diffs
        |> Enum.reduce(back_queue, fn {diff_x, diff_y}, acc ->
          new_coord = {x + diff_x, y + diff_y}
          value_neighbor = Map.get(cave_map, new_coord, 9)

          if value_neighbor > value and value_neighbor < 9 and
               not MapSet.member?(current_basin, new_coord) do
            [{new_coord, value_neighbor} | acc]
          else
            acc
          end
        end)

      find_basin({rest, back_queue}, cave_map, current_basin)
    end
  end

  def task1(input) do
    input
    |> low_points()
    |> Enum.reduce(0, fn {_, value}, acc -> acc + value + 1 end)
  end

  def task2(input) do
    input
    |> low_points()
    |> Enum.map(fn {coord, value} ->
      find_basin({[{coord, value}], []}, input, MapSet.new())
    end)
    |> Enum.sort_by(&MapSet.size/1, :desc)
    |> Enum.take(3)
    |> Enum.reduce(1, &(&2 * MapSet.size(&1)))
  end
end

input = Day9.import("input_day09.txt")

input
|> Day9.task1()
|> IO.puts()

input
|> Day9.task2()
|> IO.puts()
