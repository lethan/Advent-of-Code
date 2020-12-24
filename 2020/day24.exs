defmodule Day24 do

  @directions ~w(east west northeast northwest southeast southwest)a

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      Regex.scan(~r/(se|sw|ne|nw|e|w)/, x, capture: :all_but_first)
      |> List.flatten
      |> Enum.map(fn y ->
        case y do
          "e" ->
            :east
          "w" ->
            :west
          "se" ->
            :southeast
          "sw" ->
            :southwest
          "ne" ->
            :northeast
          "nw" ->
            :northwest
        end
      end)
    end)
  end

  def next_coordinate(direction, {x, y}) do
    case direction do
      :east ->
        {x + 2, y}
      :west ->
        {x - 2, y}
      :northeast ->
        {x + 1, y + 1}
      :southwest ->
        {x - 1, y - 1}
      :northwest ->
        {x - 1, y + 1}
      :southeast ->
        {x + 1, y - 1}
    end
  end

  def flip_tile(coord, map) do
    Map.update(map, coord, :black, fn existing_value ->
      case existing_value do
        :white ->
          :black
        :black ->
          :white
      end
    end)
  end

  def tile_map(directions) do
    directions
    |> Enum.reduce(%{}, fn directions, acc ->
      Enum.reduce(directions, {0, 0}, &next_coordinate/2)
      |> flip_tile(acc)
    end)
  end

  def number_black_neighbors(map) do
    map
    |> Enum.filter(fn {_, val} ->
      val == :black
    end)
    |> Enum.reduce(%{}, fn {coord, _}, acc ->
      Enum.reduce(@directions, acc, fn direction, acc2 ->
        Map.update(acc2, next_coordinate(direction, coord), 1, &(&1 + 1))
      end)
    end)
  end

  def new_day_map(map) do
    neighbors = number_black_neighbors(map)

    new_map = neighbors
    |> Enum.filter(&(elem(&1, 1) == 2))
    |> Enum.reduce(%{}, fn {coord, _}, acc ->
      Map.put(acc, coord, :black)
    end)

    neighbors
    |> Enum.filter(&(elem(&1, 1) == 1))
    |> Enum.reduce(new_map, fn {coord, _}, acc ->
      if Map.get(map, coord, :white) == :black do
        Map.put(acc, coord, :black)
      else
        acc
      end
    end)
  end

  def task1(input) do
    input
    |> tile_map
    |> Enum.count(fn {_, x} -> x == :black end)
  end

  def task2(input) do
    map = input
    |> tile_map

    Enum.reduce(1..100, map, fn _, acc -> new_day_map(acc) end)
    |> Enum.count
  end
end

input = Day24.import("input_day24.txt")

input
|> Day24.task1
|> IO.puts

input
|> Day24.task2
|> IO.puts
