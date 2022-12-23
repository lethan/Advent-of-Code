Code.require_file("zipper.ex", "../lib")

defmodule AOC2022.Day23 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {field, x}, acc2 ->
        case field do
          "#" ->
            Map.put(acc2, {x, y}, :elf)

          _ ->
            acc2
        end
      end)
    end)
  end

  defp move_north(map, {x, y}) do
    for(dx <- -1..1, do: {x + dx, y - 1})
    |> Enum.any?(fn coord -> Map.get(map, coord) end)
    |> case do
      false ->
        {x, y - 1}

      true ->
        false
    end
  end

  defp move_south(map, {x, y}) do
    for(dx <- -1..1, do: {x + dx, y + 1})
    |> Enum.any?(fn coord -> Map.get(map, coord) end)
    |> case do
      false ->
        {x, y + 1}

      true ->
        false
    end
  end

  defp move_west(map, {x, y}) do
    for(dy <- -1..1, do: {x - 1, y + dy})
    |> Enum.any?(fn coord -> Map.get(map, coord) end)
    |> case do
      false ->
        {x - 1, y}

      true ->
        false
    end
  end

  defp move_east(map, {x, y}) do
    for(dy <- -1..1, do: {x + 1, y + dy})
    |> Enum.any?(fn coord -> Map.get(map, coord) end)
    |> case do
      false ->
        {x + 1, y}

      true ->
        false
    end
  end

  def move_elfs(map, directions) do
    new_map =
      map
      |> Enum.reduce(%{}, fn {{x, y} = coord, _}, acc ->
        for(
          x_diff <- -1..1,
          y_diff <- -1..1,
          x_diff != 0 or y_diff != 0,
          do: {x + x_diff, y + y_diff}
        )
        |> Enum.any?(fn tmp_coord -> Map.get(map, tmp_coord) end)
        |> case do
          true ->
            directions
            |> Enum.find_value(fn fun -> fun.(map, coord) end)
            |> case do
              {_, _} = new_coord ->
                Map.update(acc, new_coord, [coord], fn list -> [coord | list] end)

              _ ->
                Map.update(acc, coord, [coord], fn list -> [coord | list] end)
            end

          false ->
            Map.update(acc, coord, [coord], fn list -> [coord | list] end)
        end
      end)
      |> Enum.reduce(%{}, fn {coord, list}, acc ->
        case list do
          [_] ->
            Map.put(acc, coord, :elf)

          list ->
            list
            |> Enum.reduce(acc, fn tmp_coord, acc2 ->
              Map.put(acc2, tmp_coord, :elf)
            end)
        end
      end)

    {elem, zipper} = Zipper.dequeue(directions)
    new_directions = Zipper.enqueue(zipper, elem)

    {new_map, new_directions}
  end

  defp default_directions() do
    [&move_north/2, &move_south/2, &move_west/2, &move_east/2]
    |> Enum.into(Zipper.new())
  end

  def task1(input) do
    {map, _} =
      1..10
      |> Enum.reduce({input, default_directions()}, fn _, {map, directions} ->
        move_elfs(map, directions)
      end)

    {x_min, x_max} =
      map
      |> Enum.map(fn {{x, _}, _} -> x end)
      |> Enum.min_max()

    {y_min, y_max} =
      map
      |> Enum.map(fn {{_, y}, _} -> y end)
      |> Enum.min_max()

    (x_max - x_min + 1) * (y_max - y_min + 1) - Enum.count(map)
  end

  def task2(input) do
    Stream.unfold(1, fn n -> {n, n + 1} end)
    |> Enum.reduce_while({input, default_directions()}, fn round, {map, directions} ->
      {new_map, new_directions} = move_elfs(map, directions)

      case new_map == map do
        true ->
          {:halt, round}

        false ->
          {:cont, {new_map, new_directions}}
      end
    end)
  end
end

input = AOC2022.Day23.import("input_day23.txt")

input
|> AOC2022.Day23.task1()
|> IO.puts()

input
|> AOC2022.Day23.task2()
|> IO.puts()
