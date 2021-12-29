Code.require_file("priority_queue.ex", "../lib")

defmodule CaveMap do
  @derive {Inspect, only: [:original_size, :dimension]}
  defstruct original_size: nil, map: nil, dimension: nil

  def new(string, dimension \\ 1) when is_bitstring(string) do
    {map, original_size} =
      string
      |> String.split("\n", trim: true)
      |> Enum.map(fn x ->
        x
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)
        |> Enum.with_index()
      end)
      |> Enum.with_index()
      |> Enum.reduce({%{}, {0, 0}}, fn {row, y}, acc ->
        Enum.reduce(row, acc, fn {value, x}, {acc2, _} ->
          {Map.put(acc2, {x, y}, value), {x + 1, y + 1}}
        end)
      end)

    %__MODULE__{original_size: original_size, map: map, dimension: dimension}
  end

  def set_dimension(cave = %__MODULE__{}, dimension) do
    %__MODULE__{cave | dimension: dimension}
  end

  def size(%__MODULE__{original_size: {x, y}, dimension: dimension}) do
    {x * dimension, y * dimension}
  end

  def get_value(cave = %__MODULE__{}, {x, y}), do: get_value(cave, x, y)

  def get_value(%__MODULE__{}, x, y) when x < 0 or y < 0, do: nil

  def get_value(%__MODULE__{original_size: {org_x, org_y}, dimension: dimension, map: map}, x, y) do
    cond do
      dimension * org_x <= x or dimension * org_y <= y ->
        nil

      true ->
        map_x = rem(x, org_x)
        map_y = rem(y, org_y)
        steps_x = div(x, org_x)
        steps_y = div(y, org_y)

        value = map[{map_x, map_y}]

        rem(value + steps_x + steps_y - 1, 9) + 1
    end
  end
end

defmodule Day15 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> CaveMap.new()
  end

  def risk_levels(map = %CaveMap{}, destination) do
    risk_levels(
      PriorityQueue.new() |> PriorityQueue.insert(0, {0, 0}),
      MapSet.new([{0, 0}]),
      map,
      destination
    )
  end

  def risk_levels(queue = %PriorityQueue{}, visited, map, destination) do
    {cost, coord = {x, y}, new_queue} = PriorityQueue.get(queue)

    case coord == destination do
      true ->
        cost

      false ->
        {new_queue, visited} =
          for(
            diff_x <- -1..1,
            diff_y <- -1..1,
            abs(diff_x) != abs(diff_y),
            do: {x + diff_x, y + diff_y}
          )
          |> Enum.reduce({new_queue, visited}, fn visit_coord,
                                                  acc = {current_queue, current_visisted} ->
            case MapSet.member?(visited, visit_coord) do
              false ->
                case CaveMap.get_value(map, visit_coord) do
                  value when not is_nil(value) ->
                    {PriorityQueue.insert(current_queue, cost + value, visit_coord),
                     MapSet.put(current_visisted, visit_coord)}

                  nil ->
                    acc
                end

              true ->
                acc
            end
          end)

        risk_levels(new_queue, visited, map, destination)
    end
  end

  def task1(input) do
    {x, y} = input |> CaveMap.size()
    destination = {x - 1, y - 1}

    input
    |> risk_levels(destination)
  end

  def task2(input) do
    input =
      input
      |> CaveMap.set_dimension(5)

    {x, y} = input |> CaveMap.size()
    destination = {x - 1, y - 1}

    input
    |> risk_levels(destination)
  end
end

input = Day15.import("input_day15.txt")

input
|> Day15.task1()
|> IO.puts()

input
|> Day15.task2()
|> IO.puts()
