defmodule AoC.Year2020.Day20 do
  alias AoC.Year2020.Day20.Tile

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(&Tile.new/1)
  end

  def import_pattern(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn list ->
      String.graphemes(list)
      |> Enum.with_index()
      |> Enum.reject(fn {val, _} -> val == " " end)
    end)
    |> Enum.with_index()
    |> Enum.reduce({[], nil}, fn {list, y}, acc ->
      list
      |> Enum.reduce(acc, fn {_, x}, {result_list, first_coord} ->
        first_coord = first_coord || {x, y}
        {x_start, y_start} = first_coord
        {[{x - x_start, y - y_start} | result_list], first_coord}
      end)
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  def tasks(input, monster) do
    {:ok, tile_map} =
      input
      |> Tile.Map.new()

    task1(tile_map)
    |> IO.puts()

    task2(tile_map, monster)
    |> IO.puts()
  end

  def task1(tile_map) do
    dimensions = Tile.Map.dimensions(tile_map)

    for x <- [0, dimensions - 1],
        y <- [0, dimensions - 1] do
      {x, y}
    end
    |> Enum.map(fn {x, y} ->
      Tile.Map.tile_at(tile_map, x, y)
      |> Tile.id()
    end)
    |> Enum.reduce(&(&1 * &2))
  end

  def task2(tile_map, monster) do
    Enum.find_value(0..3, fn rotations ->
      Enum.find_value([false, true], fn flipped ->
        image =
          tile_map
          |> Tile.Map.rotate_clockwise(rotations)
          |> (fn tmp_tile_map ->
                if flipped do
                  Tile.Map.flip_horizontally(tmp_tile_map)
                else
                  tmp_tile_map
                end
              end).()
          |> Tile.Map.to_image()

        found_coords =
          image
          |> Enum.filter(fn {_, value} -> value == :wave end)
          |> Enum.reduce([], fn {coord, _}, acc ->
            if pattern_match?(monster, coord, image) do
              [coord | acc]
            else
              acc
            end
          end)

        unless Enum.empty?(found_coords) do
          found_coords
          |> Enum.reduce(image, fn coord, acc ->
            set_image_with_pattern(monster, coord, acc)
          end)
          |> Enum.filter(fn {_, val} -> val == :wave end)
          |> Enum.count()
        end
      end)
    end)
  end

  defp pattern_match?([], _coord, _image), do: true

  defp pattern_match?([{x_diff, y_diff} | rest], coord = {x, y}, image) do
    Map.get(image, {x + x_diff, y + y_diff}, :flat) == :wave and
      pattern_match?(rest, coord, image)
  end

  defp set_image_with_pattern([], _coord, image), do: image

  defp set_image_with_pattern([{x_diff, y_diff} | rest], coord = {x, y}, image) do
    set_image_with_pattern(rest, coord, Map.put(image, {x + x_diff, y + y_diff}, :monster))
  end
end

input = AoC.Year2020.Day20.import("input/2020/input_day20.txt")
monster = AoC.Year2020.Day20.import_pattern("input/2020/input_day20_monster.txt")

input
|> AoC.Year2020.Day20.tasks(monster)
