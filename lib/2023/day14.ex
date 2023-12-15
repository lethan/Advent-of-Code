defmodule AoC.Year2023.Day14 do
  def import(file) do
    content = File.read!(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({%{}, {0, 0}}, fn {str, row}, {acc, {x_dim, y_dim}} ->
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce({acc, {x_dim, y_dim}}, fn {s, column}, {acc, {x_dim, y_dim}} ->
        x_dim = if column > x_dim, do: column, else: x_dim
        y_dim = if row > y_dim, do: row, else: y_dim

        case s do
          "." -> {acc, {x_dim, y_dim}}
          "O" -> {Map.put(acc, {column, row}, :stone), {x_dim, y_dim}}
          "#" -> {Map.put(acc, {column, row}, :blokade), {x_dim, y_dim}}
        end
      end)
    end)
  end

  defp sorter(dimension, direction) do
    comp =
      case direction do
        :asc ->
          &Kernel.</2

        :desc ->
          &Kernel.>/2
      end

    fn {{x1, y1}, _}, {{x2, y2}, _} ->
      [a, b, c, d] =
        case dimension do
          :x ->
            [x1, x2, y1, y2]

          :y ->
            [y1, y2, x1, x2]
        end

      cond do
        comp.(a, b) ->
          true

        comp.(b, a) ->
          false

        comp.(c, d) ->
          true

        true ->
          false
      end
    end
  end

  defp filter(dimension, direction) do
    comp =
      case direction do
        :asc ->
          &Kernel.</2

        :desc ->
          &Kernel.>/2
      end

    fn {x, y} ->
      fn {{tx, ty}, _} ->
        case dimension do
          :x ->
            y == ty and comp.(tx, x)

          :y ->
            x == tx and comp.(ty, y)
        end
      end
    end
  end

  defp default(dimension, direction, {dim_x, dim_y}) do
    fn {x, y} ->
      case {dimension, direction} do
        {:x, :asc} ->
          {{-1, y}, :blokade}

        {:x, :desc} ->
          {{dim_x + 1, y}, :blokade}

        {:y, :asc} ->
          {{x, -1}, :blokade}

        {:y, :desc} ->
          {{x, dim_y + 1}, :blokade}
      end
    end
  end

  defp new_position(dimension, direction) do
    fn {x, y} ->
      case {dimension, direction} do
        {:x, :asc} ->
          {x + 1, y}

        {:x, :desc} ->
          {x - 1, y}

        {:y, :asc} ->
          {x, y + 1}

        {:y, :desc} ->
          {x, y - 1}
      end
    end
  end

  defp roll({map, {dim_x, dim_y}}, sorter, filter, default, new_position) do
    map =
      map
      |> Enum.filter(fn {_, v} -> v == :stone end)
      |> Enum.sort(sorter)
      |> Enum.reduce(map, fn {coord, _}, acc ->
        {new_coord, _} =
          Enum.filter(acc, filter.(coord))
          |> Enum.sort(sorter)
          |> Enum.reverse()
          |> Enum.at(0, default.(coord))

        acc
        |> Map.delete(coord)
        |> Map.put(new_position.(new_coord), :stone)
      end)

    {map, {dim_x, dim_y}}
  end

  defp roll_north(input) do
    {_, dims} = input
    dimension = :y
    direction = :asc
    sorter = sorter(dimension, direction)
    filter = filter(dimension, direction)
    default = default(dimension, direction, dims)
    new_position = new_position(dimension, direction)

    roll(input, sorter, filter, default, new_position)
  end

  defp roll_south(input) do
    {_, dims} = input
    dimension = :y
    direction = :desc
    sorter = sorter(dimension, direction)
    filter = filter(dimension, direction)
    default = default(dimension, direction, dims)
    new_position = new_position(dimension, direction)

    roll(input, sorter, filter, default, new_position)
  end

  defp roll_east(input) do
    {_, dims} = input
    dimension = :x
    direction = :desc
    sorter = sorter(dimension, direction)
    filter = filter(dimension, direction)
    default = default(dimension, direction, dims)
    new_position = new_position(dimension, direction)

    roll(input, sorter, filter, default, new_position)
  end

  defp roll_west(input) do
    {_, dims} = input
    dimension = :x
    direction = :asc
    sorter = sorter(dimension, direction)
    filter = filter(dimension, direction)
    default = default(dimension, direction, dims)
    new_position = new_position(dimension, direction)

    roll(input, sorter, filter, default, new_position)
  end

  defp cycle(input) do
    input
    |> roll_north()
    |> roll_west()
    |> roll_south()
    |> roll_east()
  end

  defp cycle(input, times) do
    {map, _} = input

    cache = %{map => 0}

    {input, _} =
      1..times
      |> Enum.reduce_while({input, cache}, fn index, {input, cache} ->
        new_input =
          {map, dims} =
          input
          |> cycle()

        if last_seen = Map.get(cache, map) do
          period = index - last_seen
          rem = rem(times - index, period)
          {map, _} = Enum.find(cache, {map, index}, fn {_, v} -> v == last_seen + rem end)

          input = {map, dims}
          {:halt, {input, cache}}
        else
          cache = Map.put(cache, map, index)
          {:cont, {new_input, cache}}
        end
      end)

    input
  end

  def print(input = {map, {dim_x, dim_y}}) do
    for(y <- 0..dim_y, x <- 0..dim_x, do: {x, y})
    |> Enum.each(fn {x, y} ->
      if x == 0 do
        IO.puts("")
      end

      symbol =
        case Map.get(map, {x, y}) do
          :stone -> "O"
          :blokade -> "#"
          _ -> "."
        end

      IO.write(symbol)
    end)

    IO.puts("")
    input
  end

  defp total_load({map, {_dim_x, dim_y}}) do
    map
    |> Enum.filter(fn {_, v} -> v == :stone end)
    |> Enum.reduce(0, fn {{_, y}, _}, acc ->
      acc + dim_y + 1 - y
    end)
  end

  def task1(input) do
    input
    |> roll_north()
    |> total_load()
  end

  def task2(input) do
    input
    |> cycle(1_000_000_000)
    |> total_load()
  end
end

# input = AoC.Year2023.Day14.import("input/2023/input_day14.txt")

# input
# |> AoC.Year2023.Day14.task1()
# |> IO.puts()

# input
# |> AoC.Year2023.Day14.task2()
# |> IO.puts()
