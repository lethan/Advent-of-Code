defmodule AoC.Year2020.Day15 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp play_game(game, stop) do
    last_value = Map.get(game, :last_value)
    seen_last_value = Map.get(game, last_value)

    {new_value, index} =
      case seen_last_value do
        {index, nil} ->
          {0, index}

        {index, index2} ->
          {index - index2, index}
      end

    game = Map.put(game, :last_value, new_value)
    game = Map.update(game, new_value, {index + 1, nil}, fn {existing_value, _} -> {index + 1, existing_value} end)

    if index + 1 == stop do
      game
    else
      play_game(game, stop)
    end
  end

  defp initial_game(input) do
    game = %{}

    input
    |> Stream.with_index()
    |> Enum.reduce(game, fn {value, index}, acc ->
      game = Map.put(acc, :last_value, value)
      Map.update(game, value, {index + 1, nil}, fn {existing_value, _} -> {index + 1, existing_value} end)
    end)
  end

  def task1(input) do
    input
    |> initial_game
    |> play_game(2020)
    |> Map.get(:last_value)
  end

  def task2(input) do
    input
    |> initial_game
    |> play_game(30_000_000)
    |> Map.get(:last_value)
  end
end

# input = AoC.Year2020.Day15.import("input/2020/input_day15.txt")

# input
# |> AoC.Year2020.Day15.task1()
# |> IO.puts()

# input
# |> AoC.Year2020.Day15.task2()
# |> IO.puts()
