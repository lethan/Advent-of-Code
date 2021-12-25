defmodule Day25 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn string ->
      string
      |> String.graphemes()
      |> Enum.map(fn x ->
        case x do
          "." ->
            :empty

          ">" ->
            :east

          "v" ->
            :south
        end
      end)
      |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> Enum.reduce({%{}, 0, 0}, fn {line, y}, {map, count_x, count_y} ->
      count_y = if y >= count_y, do: y + 1, else: count_y

      {map, count_x} =
        line
        |> Enum.reduce({map, count_x}, fn {content, x}, {map, count_x} ->
          count_x = if x >= count_x, do: x + 1, else: count_x
          {Map.put(map, {x, y}, content), count_x}
        end)

      {map, count_x, count_y}
    end)
  end

  def move({map, count_x, count_y}) do
    {new_map, changed} =
      Enum.filter(map, fn {{x, y}, content} ->
        content == :east and Map.get(map, {rem(x + 1, count_x), y}) == :empty
      end)
      |> Enum.reduce({map, false}, fn {{x, y}, content}, {map, _changed} ->
        new_map =
          map
          |> Map.put({rem(x + 1, count_x), y}, content)
          |> Map.put({x, y}, :empty)

        {new_map, true}
      end)

    {new_map, changed} =
      Enum.filter(new_map, fn {{x, y}, content} ->
        content == :south and Map.get(new_map, {x, rem(y + 1, count_y)}) == :empty
      end)
      |> Enum.reduce({new_map, changed}, fn {{x, y}, content}, {map, _changed} ->
        new_map =
          map
          |> Map.put({x, rem(y + 1, count_y)}, content)
          |> Map.put({x, y}, :empty)

        {new_map, true}
      end)

    {{new_map, count_x, count_y}, changed}
  end

  def task1(input) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(input, fn move_number, map ->
      {new_map, changed} = move(map)

      case changed do
        true ->
          {:cont, new_map}

        false ->
          {:halt, move_number}
      end
    end)
  end
end

Day25.import("input_day25.txt")
|> Day25.task1()
|> IO.puts()
