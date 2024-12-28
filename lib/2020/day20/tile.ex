defmodule AoC.Year2020.Day20.Tile do
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
      |> string_list_to_map()

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

    %__MODULE__{id: id, map: new_map, up_edge: up, right_edge: right, down_edge: down, left_edge: left}
  end

  def print(%__MODULE__{map: map}, options \\ []) do
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

  def id(%__MODULE__{id: id}), do: id

  def rotate_clockwise(tile, times \\ 1)
  def rotate_clockwise(tile = %__MODULE__{}, 0), do: tile
  def rotate_clockwise(tile, times) when times < 0, do: rotate_clockwise(tile, 4 + times)
  def rotate_clockwise(tile, times) when times >= 4, do: rotate_clockwise(tile, rem(times, 4))

  def rotate_clockwise(
        tile = %__MODULE__{map: map, up_edge: up, down_edge: down, right_edge: right, left_edge: left},
        times
      ) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, value}, acc ->
        Map.put(acc, {9 - y, x}, value)
      end)

    %__MODULE__{tile | map: new_map, up_edge: left, right_edge: up, down_edge: right, left_edge: down}
    |> rotate_clockwise(times - 1)
  end

  def rotate_counterclockwise(tile, times \\ 1), do: rotate_clockwise(tile, 4 - times)

  def flip_horizontally(tile = %__MODULE__{map: map, up_edge: up, right_edge: right, down_edge: down, left_edge: left}) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, value}, acc ->
        Map.put(acc, {9 - x, y}, value)
      end)

    new_up = Enum.reverse(up)
    new_down = Enum.reverse(down)
    new_right = Enum.reverse(left)
    new_left = Enum.reverse(right)

    %__MODULE__{
      tile
      | map: new_map,
        up_edge: new_up,
        right_edge: new_right,
        down_edge: new_down,
        left_edge: new_left
    }
  end

  def flip_vertically(tile = %__MODULE__{map: map, up_edge: up, right_edge: right, down_edge: down, left_edge: left}) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y}, value}, acc ->
        Map.put(acc, {x, 9 - y}, value)
      end)

    new_up = Enum.reverse(down)
    new_down = Enum.reverse(up)
    new_right = Enum.reverse(right)
    new_left = Enum.reverse(left)

    %__MODULE__{
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

  def match?(%__MODULE__{up_edge: up}, %__MODULE__{down_edge: down}, :up) do
    up == Enum.reverse(down)
  end

  def match?(%__MODULE__{right_edge: right}, %__MODULE__{left_edge: left}, :right) do
    right == Enum.reverse(left)
  end

  def common_edges(
        %__MODULE__{up_edge: up_a, down_edge: down_a, right_edge: right_a, left_edge: left_a},
        %__MODULE__{up_edge: up_b, down_edge: down_b, right_edge: right_b, left_edge: left_b}
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

  def to_image(%__MODULE__{map: map}) do
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
