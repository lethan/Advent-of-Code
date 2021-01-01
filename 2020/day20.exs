defmodule Tile do
  @derive {Inspect, only: [:id]}
  defstruct id: nil,
            map: %{},
            up_edge: nil,
            right_edge: nil,
            down_edge: nil,
            left_edge: nil

  @string_to_tile_symbol %{"." => :flat, "#" => :wave}
  @tile_symbol_to_string %{flat: ".", wave: "#", monster: "O"}

  defp valid_symbol(:flat), do: :flat
  defp valid_symbol(:wave), do: :wave
  defp valid_symbol(:monster), do: :monster
  defp valid_symbol(_), do: :flat

  def new(string) when is_bitstring(string) do
    [tile_id_info | tile_content] =
      string
      |> String.split("\n", trim: true)

    [tile_number] = Regex.run(~r/Tile ([0-9]+):/, tile_id_info, capture: :all_but_first)
    tile_id = String.to_integer(tile_number)

    tile_map =
      tile_content
      |> string_list_to_map

    new(tile_id, tile_map)
  end

  def new(id), do: new(id, %{})

  def new(id, map) when is_map(map) do
    new_map =
      for x <- 0..9,
          y <- 0..9 do
        {x, y}
      end
      |> Enum.reduce(%{}, fn coord, acc ->
        Map.put(acc, coord, valid_symbol(map[coord]))
      end)

    {up, right, down, left} = tile_edges(new_map)

    %Tile{id: id, map: new_map, up_edge: up, right_edge: right, down_edge: down, left_edge: left}
  end

  def print(%Tile{map: map}, options \\ []) do
    default_options = [without_edge: false, blank_space: false, output: true]
    options = Keyword.merge(default_options, options)

    range = if options[:without_edge], do: 1..8, else: 0..9

    print_list =
      Enum.reduce(range, [], fn y, list ->
        element =
          Enum.reduce(range, "", fn x, string ->
            string <> Map.get(@tile_symbol_to_string, valid_symbol(Map.get(map, {x, y})))
          end) <>
            if options[:blank_space], do: " ", else: ""

        list ++ [element]
      end)

    print_list = if options[:blank_space], do: print_list ++ [""], else: print_list

    if options[:output] do
      Enum.each(print_list, fn x -> IO.puts(x) end)
    else
      print_list
    end
  end

  def id(%Tile{id: id}), do: id

  def rotate_clockwise(tile, times \\ 1)
  def rotate_clockwise(tile = %Tile{}, 0), do: tile
  def rotate_clockwise(tile, times) when times < 0, do: rotate_clockwise(tile, 4 + times)
  def rotate_clockwise(tile, times) when times >= 4, do: rotate_clockwise(tile, rem(times, 4))

  def rotate_clockwise(
        tile = %Tile{map: map, up_edge: up, down_edge: down, right_edge: right, left_edge: left},
        times
      ) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, value}, acc ->
        Map.put(acc, {9 - y, x}, value)
      end)

    %Tile{tile | map: new_map, up_edge: left, right_edge: up, down_edge: right, left_edge: down}
    |> rotate_clockwise(times - 1)
  end

  def rotate_counterclockwise(tile, times \\ 1), do: rotate_clockwise(tile, 4 - times)

  def flip_horizontally(
        tile = %Tile{map: map, up_edge: up, right_edge: right, down_edge: down, left_edge: left}
      ) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, value}, acc ->
        Map.put(acc, {9 - x, y}, value)
      end)

    new_up = Enum.reverse(up)
    new_down = Enum.reverse(down)
    new_right = Enum.reverse(left)
    new_left = Enum.reverse(right)

    %Tile{
      tile
      | map: new_map,
        up_edge: new_up,
        right_edge: new_right,
        down_edge: new_down,
        left_edge: new_left
    }
  end

  def flip_vertically(
        tile = %Tile{map: map, up_edge: up, right_edge: right, down_edge: down, left_edge: left}
      ) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, value}, acc ->
        Map.put(acc, {x, 9 - y}, value)
      end)

    new_up = Enum.reverse(down)
    new_down = Enum.reverse(up)
    new_right = Enum.reverse(right)
    new_left = Enum.reverse(left)

    %Tile{
      tile
      | map: new_map,
        up_edge: new_up,
        right_edge: new_right,
        down_edge: new_down,
        left_edge: new_left
    }
  end

  def match?(tile_a, tile_b, :down), do: match?(tile_b, tile_a, :up)
  def match?(tile_a, tile_b, :left), do: match?(tile_b, tile_a, :right)

  def match?(%Tile{up_edge: up}, %Tile{down_edge: down}, :up) do
    up == Enum.reverse(down)
  end

  def match?(%Tile{right_edge: right}, %Tile{left_edge: left}, :right) do
    right == Enum.reverse(left)
  end

  def common_edges(
        %Tile{up_edge: up_a, down_edge: down_a, right_edge: right_a, left_edge: left_a},
        %Tile{up_edge: up_b, down_edge: down_b, right_edge: right_b, left_edge: left_b}
      ) do
    tile_a_edges = [{:up, up_a}, {:right, right_a}, {:down, down_a}, {:left, left_a}]
    tile_b_edges = [{:up, up_b}, {:right, right_b}, {:down, down_b}, {:left, left_b}]

    tile_a_edges =
      (tile_a_edges
       |> Enum.map(fn {direction, edge} -> {direction, Enum.reverse(edge)} end)) ++
        tile_a_edges

    for {a_dir, a_edge} <- tile_a_edges,
        {b_dir, b_edge} <- tile_b_edges,
        a_edge == b_edge do
      {a_dir, b_dir}
    end
    |> Enum.uniq()
  end

  def to_image(%Tile{map: map}) do
    for x <- 1..8,
        y <- 1..8 do
      {x, y}
    end
    |> Enum.reduce(%{}, fn coord = {x, y}, acc ->
      Map.put(acc, {x - 1, y - 1}, Map.get(map, coord))
    end)
  end

  defp string_list_to_map(list) do
    list
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn list ->
      Enum.with_index(Enum.map(list, fn x -> Map.get(@string_to_tile_symbol, x, :flat) end))
    end)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {xs, y}, acc ->
      Enum.reduce(xs, acc, fn {status, x}, acc2 ->
        Map.put(acc2, {x, y}, status)
      end)
    end)
  end

  defp tile_edges(tile_map) do
    Enum.reduce(0..9, {[], [], [], []}, fn value, {edge0, edge1, edge2, edge3} ->
      {
        [Map.get(tile_map, {9 - value, 0}) | edge0],
        [Map.get(tile_map, {9, 9 - value}) | edge1],
        [Map.get(tile_map, {value, 9}) | edge2],
        [Map.get(tile_map, {0, value}) | edge3]
      }
    end)
  end
end

defmodule Tile.Map do
  defstruct dimensions: 0,
            map: %{}

  @all_directions ~w(up down left right)a
  @rotations_to_direction %{0 => :right, 1 => :down, 2 => :left, 3 => :up}
  @direction_coordinate %{:up => {0, -1}, :down => {0, 1}, :right => {1, 0}, :left => {-1, 0}}

  defp reverse_direction(:up), do: :down
  defp reverse_direction(:down), do: :up
  defp reverse_direction(:right), do: :left
  defp reverse_direction(:left), do: :right

  def new(), do: %Tile.Map{}

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
        {:ok, %Tile.Map{dimensions: dimensions, map: map}}
    end
  end

  def print(tile_map = %Tile.Map{dimensions: dimensions}, options \\ []) do
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

  def tile_at(%Tile.Map{map: map}, x_coord, y_coord) do
    Map.get(map, {x_coord, y_coord})
  end

  def dimensions(%Tile.Map{dimensions: dimensions}), do: dimensions

  def rotate_clockwise(tile_map, times \\ 1)
  def rotate_clockwise(tile_map, 0), do: tile_map
  def rotate_clockwise(tile_map, times) when times < 0, do: rotate_clockwise(tile_map, 4 + times)

  def rotate_clockwise(tile_map, times) when times >= 4,
    do: rotate_clockwise(tile_map, rem(times, 4))

  def rotate_clockwise(tile_map = %Tile.Map{map: map, dimensions: dimensions}, times) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, tile}, acc ->
        Map.put(acc, {dimensions - 1 - y, x}, Tile.rotate_clockwise(tile, 1))
      end)

    %Tile.Map{tile_map | map: new_map}
    |> rotate_clockwise(times - 1)
  end

  def rotate_counterclockwise(tile_map, times \\ 1), do: rotate_clockwise(tile_map, 4 - times)

  def flip_horizontally(tile_map = %Tile.Map{map: map, dimensions: dimensions}) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, tile}, acc ->
        Map.put(acc, {dimensions - 1 - x, y}, Tile.flip_horizontally(tile))
      end)

    %Tile.Map{tile_map | map: new_map}
  end

  def flip_vertically(tile_map = %Tile.Map{map: map, dimensions: dimensions}) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, tile}, acc ->
        Map.put(acc, {x, dimensions - 1 - y}, Tile.flip_vertically(tile))
      end)

    %Tile.Map{tile_map | map: new_map}
  end

  def to_image(%Tile.Map{map: map}) do
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

defmodule Day20 do
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

  defp task1(tile_map) do
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

input = Day20.import("input_day20.txt")
monster = Day20.import_pattern("input_day20_monster.txt")

input
|> Day20.tasks(monster)
