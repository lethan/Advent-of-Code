defmodule AoC.Year2020.Day22 do
  alias AoC.Zipper

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n")
    |> Enum.map(fn x ->
      [_ | cards] = String.split(x, "\n", trim: true)

      Enum.map(cards, &String.to_integer/1)
      |> Zipper.new()
    end)
  end

  defp new_deck(), do: Zipper.new()

  defp empty_deck?(deck), do: Zipper.empty?(deck)

  defp pop_card(deck), do: Zipper.dequeue(deck)

  defp push_card(deck, value), do: Zipper.enqueue(deck, value)

  defp deck_cards(deck), do: Zipper.size(deck)

  defp deck_to_list(deck), do: Enum.to_list(deck)

  defp play_game(deck1, deck2) do
    cond do
      empty_deck?(deck1) ->
        deck2

      empty_deck?(deck2) ->
        deck1

      true ->
        {card1, new_deck1} = pop_card(deck1)
        {card2, new_deck2} = pop_card(deck2)

        if card1 > card2 do
          new_deck1 =
            new_deck1
            |> push_card(card1)
            |> push_card(card2)

          play_game(new_deck1, new_deck2)
        else
          new_deck2 =
            new_deck2
            |> push_card(card2)
            |> push_card(card1)

          play_game(new_deck1, new_deck2)
        end
    end
  end

  defp play_recursive_game(deck1, deck2, seen_decks \\ MapSet.new()) do
    cond do
      MapSet.member?(seen_decks, {deck_to_list(deck1), deck_to_list(deck2)}) ->
        {1, deck1}

      empty_deck?(deck1) ->
        {2, deck2}

      empty_deck?(deck2) ->
        {1, deck1}

      true ->
        deck1_size = deck_cards(deck1)
        deck2_size = deck_cards(deck2)
        new_seen_decks = MapSet.put(seen_decks, {deck_to_list(deck1), deck_to_list(deck2)})

        {card1, new_deck1} = pop_card(deck1)
        {card2, new_deck2} = pop_card(deck2)

        if deck1_size > card1 and deck2_size > card2 do
          # recursive game
          {tmp_deck1, _} =
            Enum.reduce(1..card1, {new_deck(), new_deck1}, fn _, {new_deck, old_deck} ->
              {card, old_deck} = pop_card(old_deck)

              if card do
                {push_card(new_deck, card), old_deck}
              else
                {new_deck, old_deck}
              end
            end)

          {tmp_deck2, _} =
            Enum.reduce(1..card2, {new_deck(), new_deck2}, fn _, {new_deck, old_deck} ->
              {card, old_deck} = pop_card(old_deck)

              if card do
                {push_card(new_deck, card), old_deck}
              else
                {new_deck, old_deck}
              end
            end)

          case play_recursive_game(tmp_deck1, tmp_deck2) do
            {1, _} ->
              new_deck1 =
                new_deck1
                |> push_card(card1)
                |> push_card(card2)

              play_recursive_game(new_deck1, new_deck2, new_seen_decks)

            {2, _} ->
              new_deck2 =
                new_deck2
                |> push_card(card2)
                |> push_card(card1)

              play_recursive_game(new_deck1, new_deck2, new_seen_decks)
          end
        else
          # normal game
          if card1 > card2 do
            new_deck1 =
              new_deck1
              |> push_card(card1)
              |> push_card(card2)

            play_recursive_game(new_deck1, new_deck2, new_seen_decks)
          else
            new_deck2 =
              new_deck2
              |> push_card(card2)
              |> push_card(card1)

            play_recursive_game(new_deck1, new_deck2, new_seen_decks)
          end
        end
    end
  end

  defp deck_score(deck) do
    deck
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {value, index} -> value * (index + 1) end)
    |> Enum.sum()
  end

  def task1(input) do
    [deck1, deck2] = input

    play_game(deck1, deck2)
    |> deck_score
  end

  def task2(input) do
    [deck1, deck2] = input
    {_, deck} = play_recursive_game(deck1, deck2)
    deck_score(deck)
  end
end

input = AoC.Year2020.Day22.import("input/2020/input_day22.txt")

input
|> AoC.Year2020.Day22.task1()
|> IO.puts()

input
|> AoC.Year2020.Day22.task2()
|> IO.puts()
