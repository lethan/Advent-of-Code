defmodule AoC.Year2020.Day23 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp new(), do: %{}

  defp new(list) when is_list(list) do
    add_many(new(), list, nil)
  end

  defp add_many(map, enum, last_value) when is_map(map) do
    enum
    |> Enum.reduce({map, last_value}, fn value, {map, prev} ->
      {add_value(map, value, prev), value}
    end)
    |> elem(0)
  end

  defp add_value(map, value, previous_value) do
    map
    |> Map.put(value, Map.get(map, previous_value, value))
    |> Map.replace(previous_value, value)
  end

  defp next_after_value(not_in_list, value, min, max) when value < min, do: next_after_value(not_in_list, max, min, max)

  defp next_after_value(not_in_list, value, min, max) do
    if value in not_in_list do
      next_after_value(not_in_list, value - 1, min, max)
    else
      value
    end
  end

  defp get_all_after(map, value, current) do
    if (next = Map.get(map, current)) == value do
      []
    else
      [next | get_all_after(map, value, next)]
    end
  end

  defp play_game_simple(list, times) when is_list(list) do
    {min, max} = Enum.min_max(list)
    [current_value | _] = list
    game = new(list)
    play_game(game, current_value, min, max, times)
  end

  defp play_game_extended(list, times) when is_list(list) do
    {min, max} = Enum.min_max(list)
    [current_value | _] = list
    last_value = List.last(list)

    game =
      new(list)
      |> add_many((max + 1)..1_000_000, last_value)

    play_game(game, current_value, min, 1_000_000, times)
  end

  defp play_game(game, _, _, _, 0), do: game

  defp play_game(game, current_value, min, max, times) do
    next3_1 = Map.get(game, current_value)
    next3_2 = Map.get(game, next3_1)
    next3_3 = Map.get(game, next3_2)

    game = Map.put(game, current_value, Map.get(game, next3_3))

    after_value = next_after_value([next3_1, next3_2, next3_3], current_value - 1, min, max)

    game =
      Map.put(game, next3_3, Map.get(game, after_value))
      |> Map.put(after_value, next3_1)

    play_game(game, Map.get(game, current_value), min, max, times - 1)
  end

  def task1(input) do
    input
    |> play_game_simple(100)
    |> get_all_after(1, 1)
    |> Enum.join()
  end

  def task2(input) do
    game =
      input
      |> play_game_extended(10_000_000)

    val1 = Map.get(game, 1)
    val2 = Map.get(game, val1)
    val1 * val2
  end
end

# input = AoC.Year2020.Day23.import("input/2020/input_day23.txt")

# input
# |> AoC.Year2020.Day23.task1()
# |> IO.puts()

# input
# |> AoC.Year2020.Day23.task2()
# |> IO.puts()
