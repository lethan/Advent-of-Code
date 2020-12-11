defmodule Day11 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn list ->
      Enum.with_index(Enum.map(list, fn x ->
        case x do
          "L" ->
            :empty
          "." ->
            :floor
          "#" ->
            :occupied
        end
      end))
    end)
    |> Enum.with_index
    |> Enum.reduce(%{}, fn {xs, y}, acc ->
      Enum.reduce(xs, acc, fn {status, x}, acc2 ->
        Map.put(acc2, {x, y}, status)
      end)
    end)
  end

  defp occupied_neighbors(map) do
    map
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      case value do
        :occupied ->
          {x, y} = key
          updates = for new_x <- (x-1)..(x+1),
            new_y <- (y-1)..(y+1),
            new_x != x or new_y != y,
            do: {new_x, new_y}
          Enum.reduce(updates, acc, &Map.update(&2, &1, 1, fn val -> val + 1 end))
        _ ->
          acc
      end
    end)
  end

  defp seat_in_direction(map, {x, y}, {x_change, y_change} = change) do
    case Map.get(map, {x + x_change, y + y_change}) do
      :floor ->
        seat_in_direction(map, {x + x_change, y + y_change}, change)
      _ ->
        {x + x_change, y + y_change}
    end
  end

  defp advanced_occupied_neighbors(map) do
    map
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      case value do
        :occupied ->
          directions = for new_x <- -1..1,
            new_y <- -1..1,
            new_x != 0 or new_y != 0,
            do: {new_x, new_y}
          updates = Enum.map(directions, &seat_in_direction(map, key, &1))
          Enum.reduce(updates, acc, &Map.update(&2, &1, 1, fn val -> val + 1 end))
        _ ->
          acc
      end
    end)
  end

  defp new_seating(map, occupied_fun, occupied_change) do
    occupied = occupied_fun.(map)
    map
    |> Enum.reduce({%{}, 0, 0}, fn {key, status}, {map, number_occupied, changes} ->
      case status do
        :floor ->
          {Map.put(map, key, :floor), number_occupied, changes}
        :empty ->
          if Map.get(occupied, key, 0) == 0 do
            {Map.put(map, key, :occupied), number_occupied + 1, changes + 1}
          else
            {Map.put(map, key, :empty), number_occupied, changes}
          end
        :occupied ->
          if Map.get(occupied, key, 0) >= occupied_change do
            {Map.put(map, key, :empty), number_occupied, changes + 1}
          else
            {Map.put(map, key, :occupied), number_occupied + 1, changes}
          end
      end
    end)
  end

  defp until_no_changes(map, occupied_fun, occupied_change \\ 4) do
    {new_map, occupied, changes} = new_seating(map, occupied_fun, occupied_change)
    if changes == 0 do
      occupied
    else
      until_no_changes(new_map, occupied_fun, occupied_change)
    end
  end

  def task1(input) do
    until_no_changes(input, &occupied_neighbors/1)
  end

  def task2(input) do
    until_no_changes(input, &advanced_occupied_neighbors/1, 5)
  end
end

input = Day11.import("input_day11.txt")

input
|> Day11.task1
|> IO.puts

input
|> Day11.task2
|> IO.puts
