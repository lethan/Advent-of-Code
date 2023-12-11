defmodule AoC.Year2023.Day4 do
  def import(file) do
    content = File.read!(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      [card, numbers] =
        str
        |> String.split(": ")

      [_, cardnumber] = String.split(card, " ", trim: true)
      cardnumber = String.to_integer(cardnumber)

      [winning_numbers, numbers_on_card] = String.split(numbers, " | ")

      winning_numbers =
        winning_numbers
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      numbers_on_card =
        numbers_on_card
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      {cardnumber, winning_numbers, numbers_on_card}
    end)
  end

  def task1(input) do
    input
    |> Enum.reduce(0, fn {_, winning_numbers, numbers}, acc ->
      acc +
        Enum.reduce(winning_numbers, 0, fn winner, acc ->
          if winner in numbers do
            if acc == 0, do: 1, else: acc * 2
          else
            acc
          end
        end)
    end)
  end

  def task2(input) do
    input
    |> Enum.reduce({%{}, 0}, fn {card, winning_numbers, numbers}, {extra, total_cards} ->
      extra = Map.update(extra, card, 1, fn x -> x + 1 end)
      copies = Map.get(extra, card)

      {extra, _} =
        Enum.reduce(winning_numbers, {extra, 0}, fn winner, {extra, count} = acc ->
          if winner in numbers do
            count = count + 1
            extra = Map.update(extra, card + count, copies, fn x -> x + copies end)
            {extra, count}
          else
            acc
          end
        end)

      {extra, total_cards + copies}
    end)
    |> elem(1)
  end
end

# input = AoC.Year2023.Day4.import("input/2023/input_day04.txt")

# input
# |> AoC.Year2023.Day4.task1()
# |> IO.puts()

# input
# |> AoC.Year2023.Day4.task2()
# |> IO.puts()
