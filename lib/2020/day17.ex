defmodule AoC.Year2020.Day17 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn value ->
      value
      |> String.graphemes()
      |> Enum.map(&(&1 == "#"))
      |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {list, y}, acc ->
      list
      |> Enum.filter(fn {active, _} -> active end)
      |> Enum.reduce(acc, fn {_, x}, acc2 -> Map.put(acc2, {x, y, 0}, :active) end)
    end)
  end

  defp updates({x, y, z}) do
    for new_x <- (x - 1)..(x + 1),
        new_y <- (y - 1)..(y + 1),
        new_z <- (z - 1)..(z + 1),
        new_x != x or new_y != y or new_z != z,
        do: {new_x, new_y, new_z}
  end

  defp updates({x, y, z, w}) do
    for new_x <- (x - 1)..(x + 1),
        new_y <- (y - 1)..(y + 1),
        new_z <- (z - 1)..(z + 1),
        new_w <- (w - 1)..(w + 1),
        new_x != x or new_y != y or new_z != z or new_w != w,
        do: {new_x, new_y, new_z, new_w}
  end

  defp active_neighbors(map) do
    map
    |> Enum.reduce(%{}, fn {coord, _}, acc ->
      Enum.reduce(updates(coord), acc, &Map.update(&2, &1, 1, fn val -> val + 1 end))
    end)
  end

  defp convert_to_4d(map) do
    map
    |> Enum.reduce(%{}, fn {{x, y, z}, active}, acc -> Map.put(acc, {x, y, z, 0}, active) end)
  end

  defp cycle(map, 0), do: map

  defp cycle(map, cycles) do
    neighbors = active_neighbors(map)

    new_map =
      neighbors
      |> Enum.filter(&(elem(&1, 1) == 3))
      |> Enum.reduce(%{}, &Map.put(&2, elem(&1, 0), :active))

    neighbors
    |> Enum.filter(&(elem(&1, 1) == 2))
    |> Enum.reduce(new_map, fn {coord, _}, acc ->
      if Map.get(map, coord) == :active do
        Map.put(acc, coord, :active)
      else
        acc
      end
    end)
    |> cycle(cycles - 1)
  end

  def print(map) do
    {min_x, max_x} =
      map
      |> Enum.map(&elem(elem(&1, 0), 0))
      |> Enum.min_max()

    {min_y, max_y} =
      map
      |> Enum.map(&elem(elem(&1, 0), 1))
      |> Enum.min_max()

    {min_z, max_z} =
      map
      |> Enum.map(&elem(elem(&1, 0), 2))
      |> Enum.min_max()

    {min_w, max_w, w_status} =
      map
      |> Map.to_list()
      |> hd
      |> elem(0)
      |> tuple_size
      |> case do
        4 ->
          map
          |> Enum.map(&elem(elem(&1, 0), 3))
          |> Enum.min_max()
          |> Tuple.append(true)

        _ ->
          {0, 0, false}
      end

    Enum.each(min_w..max_w, fn w ->
      Enum.each(min_z..max_z, fn z ->
        IO.write("z=#{z}")

        if w_status do
          IO.write(", w=#{w}")
        end

        IO.puts("")

        Enum.each(min_y..max_y, fn y ->
          Enum.each(min_x..max_x, fn x ->
            coord =
              if w_status do
                {x, y, z, w}
              else
                {x, y, z}
              end

            IO.write(
              if Map.get(map, coord) == :active do
                "#"
              else
                "."
              end
            )
          end)

          IO.puts("")
        end)

        IO.puts("")
      end)
    end)
  end

  def task1(input) do
    input
    |> cycle(6)
    |> Enum.count()
  end

  def task2(input) do
    input
    |> convert_to_4d
    |> cycle(6)
    |> Enum.count()
  end
end

input = AoC.Year2020.Day17.import("input/2020/input_day17.txt")

input
|> AoC.Year2020.Day17.task1()
|> IO.puts()

input
|> AoC.Year2020.Day17.task2()
|> IO.puts()
