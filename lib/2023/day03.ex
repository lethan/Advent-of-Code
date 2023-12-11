defmodule AoC.Year2023.Day3 do
  def import(file) do
    content = File.read!(file)

    {map, values, symbols, _, _} =
      content
      |> String.split("\n", trim: true)
      |> Enum.reduce({%{}, %{}, %{}, 0, 0}, fn str, {map, values, symbols, current_number, row} ->
        {map, values, symbols, current_number, _, is_number} =
          String.graphemes(str)
          |> Enum.reduce({map, values, symbols, current_number, 0, false}, fn graph,
                                                                              {map, values,
                                                                               symbols,
                                                                               current_number,
                                                                               column,
                                                                               is_number} ->
            case graph do
              "." ->
                current_number = if is_number, do: current_number + 1, else: current_number
                {map, values, symbols, current_number, column + 1, false}

              x when x in ~w{0 1 2 3 4 5 6 7 8 9} ->
                number = String.to_integer(x)

                values =
                  Map.update(values, current_number, number, fn val -> val * 10 + number end)

                map = Map.put(map, {column, row}, current_number)
                {map, values, symbols, current_number, column + 1, true}

              symbol ->
                current_number = if is_number, do: current_number + 1, else: current_number
                map = Map.put(map, {column, row}, symbol)

                symbols =
                  Map.update(symbols, symbol, [{column, row}], fn list ->
                    [{column, row} | list]
                  end)

                {map, values, symbols, current_number, column + 1, false}
            end
          end)

        current_number = if is_number, do: current_number + 1, else: current_number

        {map, values, symbols, current_number, row + 1}
      end)

    {map, values, symbols}
  end

  def task1(input) do
    {map, values, symbols} = input

    symbols
    |> Enum.reduce(MapSet.new(), fn {_symbol, list}, acc ->
      Enum.reduce(list, acc, fn {x, y}, acc ->
        for(
          new_x <- (x - 1)..(x + 1),
          new_y <- (y - 1)..(y + 1),
          new_x != x or new_y != y,
          do: {new_x, new_y}
        )
        |> Enum.reduce(acc, fn coord, acc ->
          val = Map.get(map, coord)
          if is_integer(val), do: MapSet.put(acc, val), else: acc
        end)
      end)
    end)
    |> Enum.reduce(0, fn number, acc -> acc + Map.get(values, number) end)
  end

  def task2(input) do
    {map, values, symbols} = input

    Map.get(symbols, "*")
    |> Enum.reduce(0, fn {x, y}, acc ->
      mapset =
        for(
          new_x <- (x - 1)..(x + 1),
          new_y <- (y - 1)..(y + 1),
          new_x != x or new_y != y,
          do: {new_x, new_y}
        )
        |> Enum.reduce(MapSet.new(), fn coord, mapset ->
          val = Map.get(map, coord)
          if is_integer(val), do: MapSet.put(mapset, val), else: mapset
        end)

      if MapSet.size(mapset) == 2 do
        gear =
          MapSet.to_list(mapset)
          |> Enum.map(&Map.get(values, &1))
          |> Enum.product()

        gear + acc
      else
        acc
      end
    end)
  end
end

# input = AoC.Year2023.Day3.import("input/2023/input_day03.txt")

# input
# |> AoC.Year2023.Day3.task1()
# |> IO.puts()

# input
# |> AoC.Year2023.Day3.task2()
# |> IO.puts()
