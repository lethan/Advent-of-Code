defmodule Day21 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn string ->
      [_, player, _, _, position] =
        string
        |> String.split(" ")

      {String.to_integer(player), String.to_integer(position), 0}
    end)
  end

  defp deterministic_dice(sides, start \\ 1, step \\ 1) do
    {start,
     fn current_roll ->
       case rem(current_roll + step, sides) do
         0 ->
           sides

         value ->
           value
       end
     end}
  end

  defp get_dice_roll({roll, roll_function}), do: {roll, {roll_function.(roll), roll_function}}

  defp dirac_dice(sides, number_of_rolls) do
    dice = 1..sides

    Enum.reduce(1..(number_of_rolls - 1)//1, dice |> Enum.map(&List.wrap/1), fn _, acc ->
      for x <- acc,
          y <- dice,
          do: [y | x]
    end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.frequencies()
  end

  defp update_player_info(players, player_id, moves) do
    {player, position, score} =
      players
      |> Enum.at(player_id)

    position =
      case rem(position + moves, 10) do
        0 ->
          10

        value ->
          value
      end

    score = score + position

    players
    |> List.replace_at(player_id, {player, position, score})
  end

  defp winning_distribution(players, target_score, dice, turn \\ 0, cache \\ %{})

  defp winning_distribution(players, _target_score, _dice, turn, cache)
       when is_map_key(cache, {players, turn}) do
    {Map.get(cache, {players, turn}), cache}
  end

  defp winning_distribution(players, target_score, dice, turn, cache) do
    {results, _} =
      players
      |> Enum.reduce({[], true}, fn {_, _, score}, {list, searching} ->
        if searching and score >= target_score do
          {[1 | list], false}
        else
          {[0 | list], searching}
        end
      end)

    results =
      results
      |> Enum.reverse()

    if Enum.any?(results, fn result -> result == 1 end) do
      cache = Map.put(cache, {players, turn}, results)
      {results, cache}
    else
      {results, new_cache} =
        dice
        |> Enum.reduce({results, cache}, fn {moves, frequency}, {results, cache} ->
          {sub_results, new_cache} =
            winning_distribution(
              update_player_info(players, turn, moves),
              target_score,
              dice,
              rem(turn + 1, Enum.count(players)),
              cache
            )

          results =
            sub_results
            |> Enum.map(fn val -> val * frequency end)
            |> Enum.zip_with(results, fn a, b -> a + b end)

          {results, new_cache}
        end)

      cache = Map.put(new_cache, {players, turn}, results)
      {results, cache}
    end
  end

  def task1(input) do
    dice = deterministic_dice(100)

    player_count = input |> Enum.count()

    {rolls, {_, _, score}} =
      Stream.unfold(0, &{&1, &1 + 1})
      |> Enum.reduce_while({input, dice}, fn turn, {player_list, dice} ->
        player_id = rem(turn, player_count)

        {sum, dice} =
          1..3
          |> Enum.reduce({0, dice}, fn _, {sum, dice} ->
            {roll, dice} = get_dice_roll(dice)
            {sum + roll, dice}
          end)

        player_list = update_player_info(player_list, player_id, sum)

        if player_list |> Enum.at(player_id) |> elem(2) >= 1000 do
          {:halt, {3 * (turn + 1), Enum.at(player_list, rem(player_id + 1, player_count))}}
        else
          {:cont, {player_list, dice}}
        end
      end)

    rolls * score
  end

  def task2(input) do
    {results, _} =
      input
      |> winning_distribution(21, dirac_dice(3, 3))

    results
    |> Enum.max()
  end
end

input = Day21.import("input_day21.txt")

input
|> Day21.task1()
|> IO.puts()

input
|> Day21.task2()
|> IO.puts()
