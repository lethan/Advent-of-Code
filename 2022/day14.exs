defmodule AOC2022.Day14 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn str, acc ->
      [first | rest] =
        str
        |> String.split(" -> ")
        |> Enum.map(fn str ->
          str
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)
          |> List.to_tuple()
        end)

      {acc, _} =
        rest
        |> Enum.reduce({Map.put(acc, first, :rock), first}, fn {x1, y1}, {acc2, {x2, y2}} ->
          acc2 =
            for(x <- x1..x2, y <- y1..y2, do: {x, y})
            |> Enum.reduce(acc2, &Map.put(&2, &1, :rock))

          {acc2, {x1, y1}}
        end)

      acc
    end)
  end

  def pour_sand(map, with_floor \\ false, start_position \\ {500, 0}) do
    bounds =
      map
      |> Map.keys()
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort(:desc)
      |> List.first()

    pour_sand(map, start_position, bounds + 1, 0, start_position, with_floor)
  end

  def pour_sand(_map, {_x, y}, out_of_bounds, sand_number, _start_position, false)
      when y >= out_of_bounds do
    sand_number
  end

  def pour_sand(map, {x, y}, _out_of_bounds, sand_number, {x, y}, _floor)
      when is_map_key(map, {x, y}) do
    sand_number
  end

  def pour_sand(map, {x, y}, out_of_bounds, sand_number, start_position, with_floor) do
    cond do
      with_floor and y == out_of_bounds ->
        map = Map.put(map, {x, y}, :sand)
        pour_sand(map, start_position, out_of_bounds, sand_number + 1, start_position, with_floor)

      is_nil(Map.get(map, {x, y + 1})) ->
        pour_sand(map, {x, y + 1}, out_of_bounds, sand_number, start_position, with_floor)

      is_nil(Map.get(map, {x - 1, y + 1})) ->
        pour_sand(map, {x - 1, y + 1}, out_of_bounds, sand_number, start_position, with_floor)

      is_nil(Map.get(map, {x + 1, y + 1})) ->
        pour_sand(map, {x + 1, y + 1}, out_of_bounds, sand_number, start_position, with_floor)

      true ->
        map = Map.put(map, {x, y}, :sand)
        pour_sand(map, start_position, out_of_bounds, sand_number + 1, start_position, with_floor)
    end
  end

  def task1(input) do
    input
    |> pour_sand()
  end

  def task2(input) do
    input
    |> pour_sand(true)
  end
end

input = AOC2022.Day14.import("input_day14.txt")

input
|> AOC2022.Day14.task1()
|> IO.puts()

input
|> AOC2022.Day14.task2()
|> IO.puts()
