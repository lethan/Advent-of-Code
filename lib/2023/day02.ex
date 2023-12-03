defmodule AOC.Year2023.Day2 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      [game, plays] = String.split(str, ": ")

      [_, id] = String.split(game, " ")
      id = String.to_integer(id)

      plays = String.split(plays, "; ")
      |> Enum.map(fn x ->
        x
        |> String.split(", ")
        |> Enum.map(fn t ->
          [count, color] = String.split(t, " ")
          {String.to_atom(color), String.to_integer(count)}
        end)
      end)

      {id, plays}
    end)
  end

  defp possible_game(allowed, {_id, plays}) do
     Enum.reduce_while(allowed, true, fn {color, amount}, _ ->
      if Enum.any?(plays, fn play ->
        Enum.any?(play, fn {play_color, play_amount} ->
          if play_color == color and play_amount > amount, do: true, else: false
        end)
      end) do
        {:halt, false}
      else
        {:cont, true}
      end
    end)
  end

  defp minimum_set({_id, plays}) do
    Enum.reduce(plays, %{blue: 0, green: 0, red: 0}, fn play, acc ->
      Enum.reduce(play, acc, fn {color, amount}, acc ->
        Map.update(acc, color, amount, fn val -> if amount > val, do: amount, else: val end)
      end)
    end)
  end

  def task1(input) do
    input
    |> Enum.filter(&possible_game([{:red, 12}, {:green, 13}, {:blue, 14}], &1))
    |> Enum.reduce(0, fn {id, _}, acc -> acc + id end)
  end

  def task2(input) do
    input
    |> Enum.map(&minimum_set/1)
    |> Enum.reduce(0, fn %{green: green, blue: blue, red: red}, acc -> acc + green * blue * red end)
  end
end

# input = AOC2023.Day2.import("input_day02.txt")

# input
# |> AOC2023.Day2.task1()
# |> IO.puts()

# input
# |> AOC2023.Day2.task2()
# |> IO.puts()
