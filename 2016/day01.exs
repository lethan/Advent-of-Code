defmodule AOC2016.Day1 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.split(", ")
    |> Enum.map(fn str ->
      {direction, distance} =
        str
        |> String.split_at(1)

      direction =
        case direction do
          "L" -> :left
          "R" -> :right
        end

      distance = String.to_integer(distance)
      {direction, distance}
    end)
  end

  def move(moves, position \\ {0, 0}, direction \\ {0, 1}, visited \\ %{}, allow_revisit \\ true)
  def move([], position, _, _, _), do: position

  def move(
        [{rotation, distance} | rest],
        position,
        {dir_x, dir_y},
        visited,
        allow_revisit
      ) do
    {dir_x, dir_y} =
      direction =
      case rotation do
        :right ->
          {-dir_y, dir_x}

        :left ->
          {dir_y, -dir_x}
      end

    {new_pos, visited, stopped} =
      1..distance
      |> Enum.reduce_while({position, visited, false}, fn _, {{x, y}, acc, _revisit} ->
        new_pos = {x + dir_x, y + dir_y}

        case allow_revisit do
          true ->
            visited = Map.put(acc, new_pos, true)
            {:cont, {new_pos, visited, false}}

          false ->
            case Map.get(acc, new_pos) do
              true ->
                {:halt, {new_pos, acc, true}}

              _ ->
                visited = Map.put(acc, new_pos, true)
                {:cont, {new_pos, visited, false}}
            end
        end
      end)

    case stopped do
      true ->
        new_pos

      false ->
        move(rest, new_pos, direction, visited, allow_revisit)
    end
  end

  def task1(input) do
    input
    |> move()
    |> Tuple.to_list()
    |> Enum.map(&Kernel.abs/1)
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> move({0, 0}, {0, 1}, %{}, false)
    |> Tuple.to_list()
    |> Enum.map(&Kernel.abs/1)
    |> Enum.sum()
  end
end

input = AOC2016.Day1.import("input_day01.txt")

input
|> AOC2016.Day1.task1()
|> IO.puts()

input
|> AOC2016.Day1.task2()
|> IO.puts()
