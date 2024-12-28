defmodule AoC.Year2020.Day20.Tile.Map do
  defstruct dimensions: 0,
            map: %{}

  alias AoC.Year2020.Day20.Tile

  @all_directions ~w(up down left right)a
  @rotations_to_direction %{0 => :right, 1 => :down, 2 => :left, 3 => :up}
  @direction_coordinate %{:up => {0, -1}, :down => {0, 1}, :right => {1, 0}, :left => {-1, 0}}

  defp reverse_direction(:up), do: :down
  defp reverse_direction(:down), do: :up
  defp reverse_direction(:right), do: :left
  defp reverse_direction(:left), do: :right

  def new(), do: %__MODULE__{}

  def new(list) when is_list(list) do
    list =
      list
      |> Enum.filter(fn
        %Tile{} -> true
        _ -> false
      end)

    dimensions =
      list
      |> Enum.count()
      |> :math.sqrt()
      |> ceil()

    result =
      list
      |> possible_neighbors()
      |> Enum.sort_by(fn {_, val} -> Enum.count(val) end)
      |> Enum.find_value(:error, fn {tile_id, neighbors} ->
        tile_index = Enum.find_index(list, fn val -> tile_id == Tile.id(val) end)
        tile = Enum.at(list, tile_index)
        new_list = List.delete_at(list, tile_index)

        tmp_result =
          Enum.find_value(0..3, fn n ->
            right = Map.get(@rotations_to_direction, rem(4 - n, 4))
            down = Map.get(@rotations_to_direction, rem(5 - n, 4))

            if is_list(Map.get(neighbors, right)) and is_list(Map.get(neighbors, down)) do
              tile = Tile.rotate_clockwise(tile, n)
              tile_map(tile, 0, 0, %{}, new_list, dimensions)
            end
          end)

        case tmp_result do
          :error -> nil
          map -> map
        end
      end)

    case result do
      :error ->
        {:error, "unplaceable tiles"}

      map ->
        {:ok, %__MODULE__{dimensions: dimensions, map: map}}
    end
  end

  def print(tile_map = %__MODULE__{dimensions: dimensions}, options \\ []) do
    default_options = [without_edge: true, blank_space: false]

    options =
      Keyword.merge(default_options, options)
      |> Keyword.merge(output: false)

    Enum.each(0..(dimensions - 1), fn y ->
      Enum.reduce((dimensions - 1)..0, [], fn x, acc ->
        printed =
          tile_at(tile_map, x, y)
          |> Tile.print(options)

        [printed | acc]
      end)
      |> List.zip()
      |> Enum.map(fn val ->
        Tuple.to_list(val)
        |> Enum.join()
        |> IO.puts()
      end)
    end)
  end

  def tile_at(%__MODULE__{map: map}, x_coord, y_coord) do
    Map.get(map, {x_coord, y_coord})
  end

  def dimensions(%__MODULE__{dimensions: dimensions}), do: dimensions

  def rotate_clockwise(tile_map, times \\ 1)
  def rotate_clockwise(tile_map, 0), do: tile_map
  def rotate_clockwise(tile_map, times) when times < 0, do: rotate_clockwise(tile_map, 4 + times)

  def rotate_clockwise(tile_map, times) when times >= 4,
    do: rotate_clockwise(tile_map, rem(times, 4))

  def rotate_clockwise(tile_map = %__MODULE__{map: map, dimensions: dimensions}, times) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, tile}, acc ->
        Map.put(acc, {dimensions - 1 - y, x}, Tile.rotate_clockwise(tile, 1))
      end)

    %__MODULE__{tile_map | map: new_map}
    |> rotate_clockwise(times - 1)
  end

  def rotate_counterclockwise(tile_map, times \\ 1), do: rotate_clockwise(tile_map, 4 - times)

  def flip_horizontally(tile_map = %__MODULE__{map: map, dimensions: dimensions}) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, tile}, acc ->
        Map.put(acc, {dimensions - 1 - x, y}, Tile.flip_horizontally(tile))
      end)

    %__MODULE__{tile_map | map: new_map}
  end

  def flip_vertically(tile_map = %__MODULE__{map: map, dimensions: dimensions}) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, tile}, acc ->
        Map.put(acc, {x, dimensions - 1 - y}, Tile.flip_vertically(tile))
      end)

    %__MODULE__{tile_map | map: new_map}
  end

  def to_image(%__MODULE__{map: map}) do
    map
    |> Enum.reduce(%{}, fn {{map_x, map_y}, tile}, acc ->
      Tile.to_image(tile)
      |> Enum.reduce(acc, fn {{x, y}, value}, acc2 ->
        Map.put(acc2, {map_x * 8 + x, map_y * 8 + y}, value)
      end)
    end)
  end

  defp correct_placed_tile?(tile, x_coord, y_coord, tile_map, direction) do
    case Map.get(tile_map, new_coordinate(x_coord, y_coord, direction)) do
      other_tile = %Tile{} ->
        Tile.match?(tile, other_tile, direction)

      nil ->
        true

      _ ->
        false
    end
  end

  defp new_coordinate(x_coord, y_coord, direction) do
    {x_diff, y_diff} = Map.get(@direction_coordinate, direction)
    {x_coord + x_diff, y_coord + y_diff}
  end

  defp tile_map(tile, x_coord, y_coord, current_map, unselected_tiles, dimensions) do
    valid_placement =
      @all_directions
      |> Enum.all?(fn direction ->
        correct_placed_tile?(tile, x_coord, y_coord, current_map, direction)
      end)

    with true <- valid_placement,
         new_map <- Map.put(current_map, {x_coord, y_coord}, tile),
         new_x <- rem(x_coord + 1, dimensions),
         new_y <- y_coord + div(x_coord + 1, dimensions) do
      case unselected_tiles do
        [] ->
          new_map

        _ ->
          tiles_map =
            unselected_tiles
            |> Enum.map(&Tile.id/1)
            |> MapSet.new()

          @all_directions
          |> Enum.reduce(tiles_map, fn direction, acc ->
            Map.get(new_map, new_coordinate(new_x, new_y, direction))
            |> neighbor_set(unselected_tiles, reverse_direction(direction))
            |> MapSet.intersection(acc)
          end)
          |> MapSet.to_list()
          |> Enum.find_value(:error, fn tile_id ->
            tile_index = Enum.find_index(unselected_tiles, fn val -> tile_id == Tile.id(val) end)
            new_tile = Enum.at(unselected_tiles, tile_index)
            new_unselected_tiles = List.delete_at(unselected_tiles, tile_index)

            for rotations <- 0..3,
                flipped <- [false, true] do
              Tile.rotate_clockwise(new_tile, rotations)
              |> (fn tmp_tile ->
                    if flipped do
                      Tile.flip_horizontally(tmp_tile)
                    else
                      tmp_tile
                    end
                  end).()
            end
            |> Enum.find_value(fn new_tile ->
              case tile_map(new_tile, new_x, new_y, new_map, new_unselected_tiles, dimensions) do
                :error ->
                  nil

                result ->
                  result
              end
            end)
          end)
      end
    else
      _ ->
        :error
    end
  end

  defp possible_neighbors(tile_list, neighbors \\ %{})
  defp possible_neighbors([], neighbors), do: neighbors

  defp possible_neighbors([tile1 | rest], neighbors) do
    tile1_id = Tile.id(tile1)

    new_neighbors =
      rest
      |> Enum.reduce(neighbors, fn tile2, acc ->
        tile2_id = Tile.id(tile2)

        Tile.common_edges(tile1, tile2)
        |> Enum.reduce(acc, fn {dir1, dir2}, acc2 ->
          Map.update(acc2, tile1_id, %{dir1 => [tile2_id]}, fn existing_value ->
            Map.update(existing_value, dir1, [tile2_id], fn list ->
              [tile2_id | list]
            end)
          end)
          |> Map.update(tile2_id, %{dir2 => [tile1_id]}, fn existing_value ->
            Map.update(existing_value, dir2, [tile1_id], fn list ->
              [tile1_id | list]
            end)
          end)
        end)
      end)

    possible_neighbors(rest, new_neighbors)
  end

  defp neighbors_of(tile = %Tile{}, list) do
    list
    |> Enum.reduce(%{}, fn val, acc ->
      Tile.common_edges(tile, val)
      |> Enum.reduce(acc, fn {dir1, _dir2}, acc2 ->
        Map.update(acc2, dir1, [Tile.id(val)], fn existing_value ->
          [Tile.id(val) | existing_value]
        end)
      end)
    end)
  end

  defp neighbor_set(nil, list, _direction) do
    list
    |> Enum.map(&Tile.id/1)
    |> MapSet.new()
  end

  defp neighbor_set(tile = %Tile{}, list, direction) do
    values =
      neighbors_of(tile, list)
      |> Map.get(direction)

    case values do
      nil ->
        MapSet.new([])

      val ->
        MapSet.new(val)
    end
  end
end
