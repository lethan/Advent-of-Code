defmodule Day11 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_data()
  end

  defp convert_to_data(input) do
    input
    |> Enum.map(fn x ->
      x
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, acc ->
      Enum.reduce(row, acc, fn {value, x}, acc2 ->
        Map.put(acc2, {x, y}, value)
      end)
    end)
  end

  defp stepup_point(coord = {x, y}, map) do
    case Map.fetch(map, coord) do
      {:ok, 9} ->
        for(
          new_x <- (x - 1)..(x + 1),
          new_y <- (y - 1)..(y + 1),
          new_x != x or new_y != y,
          do: {new_x, new_y}
        )
        |> Enum.reduce(Map.put(map, coord, 10), fn new_coord, acc ->
          stepup_point(new_coord, acc)
        end)

      {:ok, value} ->
        Map.put(map, coord, value + 1)

      :error ->
        map
    end
  end

  defp map_flashes(map) do
    Enum.filter(map, fn {_coord, value} -> value >= 10 end)
    |> Enum.reduce({map, 0}, fn {coord, _}, {acc, count} ->
      {Map.put(acc, coord, 0), count + 1}
    end)
  end

  defp map_step({map, flashes}), do: map_steps({map, flashes}, 1)

  defp map_steps({map, flashes}, 0), do: {map, flashes}

  defp map_steps({map, flashes}, n) do
    {new_map, new_flashes} =
      map
      |> Enum.reduce(map, fn {coord, _}, acc ->
        stepup_point(coord, acc)
      end)
      |> map_flashes()

    map_steps({new_map, flashes + new_flashes}, n - 1)
  end

  defp find_sync(map) do
    Stream.unfold(0, &{&1, &1 + 1})
    |> Enum.reduce_while(map, fn itteration, acc ->
      case Enum.all?(acc, fn {_coord, value} -> value == 0 end) do
        true ->
          {:halt, itteration}

        false ->
          {new_map, _} = map_step({acc, 0})
          {:cont, new_map}
      end
    end)
  end

  def task1(input) do
    {_, flashes} = map_steps({input, 0}, 100)
    flashes
  end

  def task2(input) do
    find_sync(input)
  end
end

input = Day11.import("input_day11.txt")

input
|> Day11.task1()
|> IO.puts()

input
|> Day11.task2()
|> IO.puts()
