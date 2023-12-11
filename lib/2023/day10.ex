defmodule AOC.Year2023.Day10 do
  def import(file) do
    content = File.read!(file)

    {map, _} =
      content
      |> String.split("\n", trim: true)
      |> Enum.reduce({%{}, 0}, fn str, {acc, row} ->
        acc =
          str
          |> String.graphemes()
          |> Enum.map(fn s ->
            case s do
              "." -> :ground
              "|" -> :north_south
              "-" -> :east_west
              "F" -> :south_east
              "7" -> :south_west
              "L" -> :north_east
              "J" -> :north_west
              "S" -> :start
            end
          end)
          |> Enum.with_index()
          |> Enum.reduce(acc, fn {type, column}, acc ->
            Map.put(acc, {column, row}, type)
          end)

        {acc, row + 1}
      end)

    map
  end

  def find_furthest(map) do
    {{x, y}, _} =
      map
      |> Enum.find(fn {_, v} -> v == :start end)

    [step_a, step_b] =
      for(
        new_x <- (x - 1)..(x + 1),
        new_y <- (y - 1)..(y + 1),
        (new_x == x and new_y != y) or (new_y == y and new_x != x),
        do: {new_x, new_y}
      )
      |> Enum.reduce([], fn coord = {new_x, new_y}, acc ->
        case {new_x - x, new_y - y, Map.get(map, coord)} do
          {-1, 0, direction} when direction in [:east_west, :south_east, :north_east] ->
            [{{new_x, new_y}, {x, y}} | acc]

          {1, 0, direction} when direction in [:east_west, :south_west, :north_west] ->
            [{{new_x, new_y}, {x, y}} | acc]

          {0, -1, direction} when direction in [:north_south, :south_east, :south_west] ->
            [{{new_x, new_y}, {x, y}} | acc]

          {0, 1, direction} when direction in [:north_south, :north_east, :north_west] ->
            [{{new_x, new_y}, {x, y}} | acc]

          _ ->
            acc
        end
      end)

    step(step_a, step_b, map)
  end

  def step(a, b, map, steps \\ 1)
  def step({step, _}, {step, _}, _map, steps), do: steps
  def step({step_a, step_b}, {step_b, step_a}, _amp, steps), do: steps - 1

  def step(a, b, map, steps) do
    [next_a, next_b] =
      [a, b]
      |> Enum.map(&next_point(elem(&1, 0), elem(&1, 1), map))

    step(next_a, next_b, map, steps + 1)
  end

  defp next_point(point = {s_x, s_y}, {p_x, p_y}, map) do
    case {Map.get(map, point), s_x - p_x, s_y - p_y} do
      {:north_south, 0, direction} ->
        {{s_x, s_y + direction}, point}

      {:east_west, direction, 0} ->
        {{s_x + direction, s_y}, point}

      {:south_east, -1, 0} ->
        {{s_x, s_y + 1}, point}

      {:south_east, 0, -1} ->
        {{s_x + 1, s_y}, point}

      {:south_west, 1, 0} ->
        {{s_x, s_y + 1}, point}

      {:south_west, 0, -1} ->
        {{s_x - 1, s_y}, point}

      {:north_east, -1, 0} ->
        {{s_x, s_y - 1}, point}

      {:north_east, 0, 1} ->
        {{s_x + 1, s_y}, point}

      {:north_west, 1, 0} ->
        {{s_x, s_y - 1}, point}

      {:north_west, 0, 1} ->
        {{s_x - 1, s_y}, point}
    end
  end

  def border(map) do
    {{x, y}, _} =
      map
      |> Enum.find(fn {_, v} -> v == :start end)

    [{step_a, direction_a}, {step_b, direction_b}] =
      for(
        new_x <- (x - 1)..(x + 1),
        new_y <- (y - 1)..(y + 1),
        (new_x == x and new_y != y) or (new_y == y and new_x != x),
        do: {new_x, new_y}
      )
      |> Enum.reduce([], fn coord = {new_x, new_y}, acc ->
        case {new_x - x, new_y - y, Map.get(map, coord)} do
          {-1, 0, direction} when direction in [:east_west, :south_east, :north_east] ->
            [{{{new_x, new_y}, {x, y}}, :left} | acc]

          {1, 0, direction} when direction in [:east_west, :south_west, :north_west] ->
            [{{{new_x, new_y}, {x, y}}, :right} | acc]

          {0, -1, direction} when direction in [:north_south, :south_east, :south_west] ->
            [{{{new_x, new_y}, {x, y}}, :up} | acc]

          {0, 1, direction} when direction in [:north_south, :north_east, :north_west] ->
            [{{{new_x, new_y}, {x, y}}, :down} | acc]

          _ ->
            acc
        end
      end)

    type =
      [direction_a, direction_b]
      |> Enum.sort()
      |> case do
        [:down, :up] -> :north_south
        [:left, :right] -> :east_west
        [:left, :up] -> :north_west
        [:down, :left] -> :south_west
        [:down, :right] -> :south_east
        [:right, :up] -> :north_east
      end

    find_border(step_a, step_b, map, %{{x, y} => type})
  end

  def find_border({step, _}, {step, _}, map, border),
    do: Map.put(border, step, Map.get(map, step))

  def find_border({step_a, step_b}, {step_b, step_a}, _map, border), do: border

  def find_border(a = {step_a, _prev_a}, b = {step_b, _prev_b}, map, border) do
    border =
      [step_a, step_b]
      |> Enum.reduce(border, &Map.put(&2, &1, Map.get(map, &1)))

    [next_a, next_b] =
      [a, b]
      |> Enum.map(&next_point(elem(&1, 0), elem(&1, 1), map))

    find_border(next_a, next_b, map, border)
  end

  def enclosed_tiles(border) do
    {_, _, _, inside} =
      border
      |> Enum.sort(fn {{x1, y1}, _}, {{x2, y2}, _} ->
        cond do
          y1 < y2 ->
            true

          y1 > y2 ->
            false

          x1 < x2 ->
            true

          true ->
            false
        end
      end)
      |> Enum.reduce({-1, -1, 0, 0}, fn {{x, y}, type},
                                        {last_y, last_x, currently_inside, inside_counter} ->
        cond do
          y != last_y and type in [:north_south, :north_west, :north_east] ->
            {y, x, 1, inside_counter}

          type in [:north_south, :north_west, :north_east] ->
            {y, x, rem(currently_inside + 1, 2),
             inside_counter + currently_inside * (x - last_x - 1)}

          true ->
            {y, x, currently_inside, inside_counter + currently_inside * (x - last_x - 1)}
        end
      end)

    inside
  end

  def task1(input) do
    input
    |> find_furthest()
  end

  def task2(input) do
    input
    |> border()
    |> enclosed_tiles()
  end
end

# input = AOC.Year2023.Day10.import("input/2023/input_day10.txt")

# input
# |> AOC.Year2023.Day10.task1()
# |> IO.puts()

# input
# |> AOC.Year2023.Day10.task2()
# |> IO.puts()
