defmodule AoC.Year2023.Day16 do
  def import(file) do
    content = File.read!(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {str, row}, acc ->
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {s, column}, acc ->
        case s do
          "." -> Map.put(acc, {column, row}, :empty)
          "|" -> Map.put(acc, {column, row}, :splitter_up_down)
          "-" -> Map.put(acc, {column, row}, :splitter_left_right)
          "/" -> Map.put(acc, {column, row}, :mirror_bottomleft_topright)
          "\\" -> Map.put(acc, {column, row}, :mirror_topleft_bottomright)
        end
      end)
    end)
  end

  defp energy_map(pending, map, visited \\ %{})
  defp energy_map([], _map, visited), do: visited

  defp energy_map([{coord = {x, y}, direction = {vx, vy}} | rest], map, visited) do
    if Map.get(visited, {coord, direction}) do
      energy_map(rest, map, visited)
    else
      case Map.get(map, coord) do
        :empty ->
          visited = Map.put(visited, {coord, direction}, 1)
          next_coord = {x + vx, y + vy}
          energy_map([{next_coord, direction} | rest], map, visited)

        :mirror_topleft_bottomright ->
          visited = Map.put(visited, {coord, direction}, 1)
          next_direction = {vy, vx}
          next_coord = {x + vy, y + vx}
          energy_map([{next_coord, next_direction} | rest], map, visited)

        :mirror_bottomleft_topright ->
          visited = Map.put(visited, {coord, direction}, 1)
          next_direction = {-vy, -vx}
          next_coord = {x - vy, y - vx}
          energy_map([{next_coord, next_direction} | rest], map, visited)

        :splitter_up_down ->
          visited = Map.put(visited, {coord, direction}, 1)

          if vx == 0 do
            next_coord = {x + vx, y + vy}
            energy_map([{next_coord, direction} | rest], map, visited)
          else
            next_coord1 = {x, y - 1}
            direction1 = {0, -1}
            next_coord2 = {x, y + 1}
            direction2 = {0, 1}
            energy_map([{next_coord1, direction1}, {next_coord2, direction2} | rest], map, visited)
          end

        :splitter_left_right ->
          visited = Map.put(visited, {coord, direction}, 1)

          if vy == 0 do
            next_coord = {x + vx, y + vy}
            energy_map([{next_coord, direction} | rest], map, visited)
          else
            next_coord1 = {x - 1, y}
            direction1 = {-1, 0}
            next_coord2 = {x + 1, y}
            direction2 = {1, 0}
            energy_map([{next_coord1, direction1}, {next_coord2, direction2} | rest], map, visited)
          end

        nil ->
          energy_map(rest, map, visited)
      end
    end
  end

  defp energized_tiles(visisted) do
    visisted
    |> Enum.uniq_by(fn {{c, _}, _} -> c end)
    |> Enum.count()
  end

  def task1(input) do
    coord = {0, 0}
    direction = {1, 0}

    energy_map([{coord, direction}], input)
    |> energized_tiles()
  end

  def task2(input) do
    {max_x, max_y} =
      input
      |> Map.keys()
      |> Enum.max()

    for(
      dir_x <- -1..1,
      dir_y <- -1..1,
      x <- 0..max_x,
      y <- 0..max_y,
      dir_x == 0 or dir_y == 0,
      dir_x != dir_y,
      (x == 0 and dir_x == 1) or (x == max_x and dir_x == -1) or (y == 0 and dir_y == 1) or (y == max_y and dir_y == -1),
      do: [{{x, y}, {dir_x, dir_y}}]
    )
    |> Enum.map(fn start ->
      energy_map(start, input)
      |> energized_tiles()
    end)
    |> Enum.max()
  end
end

# input = AoC.Year2023.Day16.import("input/2023/input_day16.txt")

# input
# |> AoC.Year2023.Day16.task1()
# |> IO.puts()

# input
# |> AoC.Year2023.Day16.task2()
# |> IO.puts()
