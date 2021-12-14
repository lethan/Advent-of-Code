defmodule Day13 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n", trim: true)
    |> convert_to_data()
  end

  defp convert_to_data(input) do
    [points, folds] = input

    points = points(points)

    folds = folds(folds)

    {points, folds}
  end

  defp points(string) do
    string
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      String.split(x, ",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.reduce(%{}, fn coord, acc ->
      Map.put(acc, coord, :dot)
    end)
  end

  defp folds(string) do
    string
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      [_, _, fold_at] = String.split(x, " ")
      [direction, position] = String.split(fold_at, "=")
      direction = String.to_atom(direction)
      position = String.to_integer(position)
      {direction, position}
    end)
  end

  defp fold_along({direction, position}, map) do
    map
    |> Enum.reduce(%{}, fn {coord, dot}, acc ->
      case direction do
        :x ->
          case coord do
            {x, y} when x > position ->
              new_x = position - (x - position)
              Map.put(acc, {new_x, y}, dot)

            coord ->
              Map.put(acc, coord, dot)
          end

        :y ->
          case coord do
            {x, y} when y > position ->
              new_y = position - (y - position)
              Map.put(acc, {x, new_y}, dot)

            coord ->
              Map.put(acc, coord, dot)
          end
      end
    end)
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

    Enum.each(min_y..max_y, fn y ->
      Enum.each(min_x..max_x, fn x ->
        IO.write(
          if Map.get(map, {x, y}) == :dot do
            "#"
          else
            " "
          end
        )
      end)

      IO.puts("")
    end)

    IO.puts("")
  end

  def task1(input) do
    {coords, folds} = input

    [first_fold | _] = folds

    fold_along(first_fold, coords)
    |> Enum.count()
  end

  def task2(input) do
    {coords, folds} = input

    folds
    |> Enum.reduce(coords, fn fold, acc ->
      fold_along(fold, acc)
    end)
    |> print()
  end
end

input = Day13.import("input_day13.txt")

input
|> Day13.task1()
|> IO.puts()

IO.puts("")

input
|> Day13.task2()
