defmodule AOC.Year2023.Day7 do
  def import(file) do
    content = File.read!(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      [hand, bid] =
        str
        |> String.split(" ")

      hand =
        String.graphemes(hand)
        |> Enum.map(fn card ->
          case Integer.parse(card) do
            {num, ""} ->
              num

            :error ->
              case card do
                "A" -> 14
                "K" -> 13
                "Q" -> 12
                "J" -> 11
                "T" -> 10
              end
          end
        end)

      {hand, String.to_integer(bid)}
    end)
  end

  defp hand_strength(hand) do
    hand
    |> Enum.reduce(%{}, fn c, acc ->
      Map.update(acc, c, 1, &(&1 + 1))
    end)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.sort(:desc)
  end

  defp hand_strength_joker(hand) do
    {jokers, map} =
      hand
      |> Enum.reduce(%{14 => 0}, fn c, acc ->
        Map.update(acc, c, 1, &(&1 + 1))
      end)
      |> Map.pop(11, 0)

    map
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.sort(:desc)
    |> List.update_at(0, &(&1 + jokers))
  end

  defp hand_sorter(
         hand_a,
         hand_b,
         hand_strength \\ &hand_strength/1,
         card_sorter \\ &card_sorter/2
       ) do
    case sort_strength(hand_strength.(hand_a), hand_strength.(hand_b)) do
      :equal ->
        card_sorter.(hand_a, hand_b)

      :greater ->
        true

      :smaller ->
        false
    end
  end

  defp sort_strength([], []), do: :equal
  defp sort_strength([0], []), do: :equal
  defp sort_strength([], [0]), do: :equal
  defp sort_strength([a | r1], [a | r2]), do: sort_strength(r1, r2)
  defp sort_strength([a | _], [b | _]) when a > b, do: :greater
  defp sort_strength([a | _], [b | _]) when a < b, do: :smaller

  defp card_sorter([], []), do: true
  defp card_sorter([a | r1], [a | r2]), do: card_sorter(r1, r2)
  defp card_sorter([a | _], [b | _]) when a > b, do: true
  defp card_sorter([a | _], [b | _]) when a < b, do: false

  defp card_sorter_joker([], []), do: true
  defp card_sorter_joker([11 | r], b), do: card_sorter_joker([1 | r], b)
  defp card_sorter_joker(a, [11 | r]), do: card_sorter_joker(a, [1 | r])
  defp card_sorter_joker([a | r1], [a | r2]), do: card_sorter_joker(r1, r2)
  defp card_sorter_joker([a | _], [b | _]) when a > b, do: true
  defp card_sorter_joker([a | _], [b | _]) when a < b, do: false

  def task1(input) do
    input
    |> Enum.sort(fn {a, _}, {b, _} -> hand_sorter(b, a) end)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {{_, bid}, i}, acc -> (i + 1) * bid + acc end)
  end

  def task2(input) do
    input
    |> Enum.sort(fn {a, _}, {b, _} ->
      hand_sorter(b, a, &hand_strength_joker/1, &card_sorter_joker/2)
    end)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {{_, bid}, i}, acc -> (i + 1) * bid + acc end)
  end
end

# input = AOC.Year2023.Day7.import("input/2023/input_day07.txt")

# input
# |> AOC.Year2023.Day7.task1()
# |> IO.puts()

# input
# |> AOC.Year2023.Day7.task2()
# |> IO.puts()
