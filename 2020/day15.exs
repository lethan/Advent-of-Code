defmodule Day15 do

  defp play_game(game, stop) do
    last_value = Map.get(game, :last_value)
    seen_last_value = Map.get(game, last_value)
    {new_value, index} = case seen_last_value do
      [index | [index2 | _]] ->
        {index - index2, index}
      [index | _] ->
        {0, index}
    end
    game = Map.put(game, :last_value, new_value)
    game = Map.update(game, new_value, [index + 1], fn [existing_value | _] -> [index + 1, existing_value] end)
    if index + 1 == stop do
      game
    else
      play_game(game, stop)
    end
  end

  defp initial_game(input) do
    game = %{}

    input
    |> Enum.with_index
    |> Enum.reduce(game, fn {value, index}, acc ->
      game = Map.put(acc, :last_value, value)
      Map.update(game, value, [index + 1], fn [existing_value | _] -> [index + 1, existing_value] end)
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
    |> play_game(30000000)
    |> Map.get(:last_value)
  end
end

input = [1, 17, 0, 10, 18, 11, 6]

input
|> Day15.task1
|> IO.puts

input
|> Day15.task2
|> IO.puts
