Code.require_file("priority_queue.ex", "../lib")

defmodule AOC2022.Day12 do
  def import(file) do
    {:ok, content} = File.read(file)

    {map, _, start, destination} =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn str ->
        str
        |> String.graphemes()
      end)
      |> Enum.reduce({%{}, 0, nil, nil}, fn row, {acc, y, start, destination} ->
        {acc, _, start, destination} =
          row
          |> Enum.reduce({acc, 0, start, destination}, fn elevation,
                                                          {acc2, x, start, destination} ->
            case elevation do
              "S" ->
                height = 0
                start = {x, y}
                {Map.put(acc2, {x, y}, height), x + 1, start, destination}

              "E" ->
                <<height::utf8>> = "z"
                height = height - ?a
                destination = {x, y}
                {Map.put(acc2, {x, y}, height), x + 1, start, destination}

              <<height::utf8>> ->
                height = height - ?a
                {Map.put(acc2, {x, y}, height), x + 1, start, destination}
            end
          end)

        {acc, y + 1, start, destination}
      end)

    {map, start, destination}
  end

  def shortest_path(map, start, destination) do
    shortest_path(
      PriorityQueue.new() |> PriorityQueue.insert(0, start),
      MapSet.new([start]),
      map,
      destination
    )
  end

  def shortest_path(queue = %PriorityQueue{}, visited, map, destination) do
    {steps, coord = {x, y}, new_queue} = PriorityQueue.get(queue)
    current_height = Map.get(map, coord)

    case coord == destination do
      true ->
        steps

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
                case Map.get(map, visit_coord) do
                  height when not is_nil(height) and height <= current_height + 1 ->
                    {PriorityQueue.insert(current_queue, steps + 1, visit_coord),
                     MapSet.put(current_visisted, visit_coord)}

                  _ ->
                    acc
                end

              true ->
                acc
            end
          end)

        shortest_path(new_queue, visited, map, destination)
    end
  end

  def find_shortest_start_path(map, start, find_elevation \\ 0) do
    find_shortest_start_path(
      PriorityQueue.new() |> PriorityQueue.insert(0, start),
      MapSet.new([start]),
      map,
      find_elevation
    )
  end

  def find_shortest_start_path(queue = %PriorityQueue{}, visited, map, find_elevation) do
    {steps, coord = {x, y}, new_queue} = PriorityQueue.get(queue)
    current_height = Map.get(map, coord)

    case current_height == find_elevation do
      true ->
        steps

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
                case Map.get(map, visit_coord) do
                  height when not is_nil(height) and height >= current_height - 1 ->
                    {PriorityQueue.insert(current_queue, steps + 1, visit_coord),
                     MapSet.put(current_visisted, visit_coord)}

                  _ ->
                    acc
                end

              true ->
                acc
            end
          end)

        find_shortest_start_path(new_queue, visited, map, find_elevation)
    end
  end

  def task1({map, start, destination}) do
    shortest_path(map, start, destination)
  end

  def task2({map, _start, destination}) do
    find_shortest_start_path(map, destination)
  end
end

input = AOC2022.Day12.import("input_day12.txt")

input
|> AOC2022.Day12.task1()
|> IO.puts()

input
|> AOC2022.Day12.task2()
|> IO.puts()
