defmodule Day22 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n")
    |> Enum.map(fn x ->
      [_ | cards] = String.split(x, "\n", trim: true)
      cards = Enum.map(cards, &String.to_integer/1)
      {cards, []}
    end)
  end

  def new_deck(), do: {[], []}

  def empty_deck?({[], []}), do: true
  def empty_deck?(_), do: false

  def pop_card({[], []}), do: {nil, {[], []}}
  def pop_card({[card | rest], others}), do: {card, {rest, others}}
  def pop_card({[], others}), do: pop_card({Enum.reverse(others), []})

  def push_card({cards, other}, value), do: {cards, [value | other]}

  def deck_cards({a, b}), do: Enum.count(a) + Enum.count(b)

  def deck_to_list({[], []}), do: []
  def deck_to_list(deck) do
    {value, new_deck} = pop_card(deck)
    [value | deck_to_list(new_deck)]
  end

  def play_game(deck1, deck2) do
    cond do
      empty_deck?(deck1) ->
        deck2
      empty_deck?(deck2) ->
        deck1
      true ->
        {card1, new_deck1} = pop_card(deck1)
        {card2, new_deck2} = pop_card(deck2)

        if card1 > card2 do
          new_deck1 = new_deck1
          |> push_card(card1)
          |> push_card(card2)
          play_game(new_deck1, new_deck2)
        else
          new_deck2 = new_deck2
          |> push_card(card2)
          |> push_card(card1)
          play_game(new_deck1, new_deck2)
        end
    end
  end

  def play_recursive_game(deck1, deck2, seen_decks \\ MapSet.new) do
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
          {tmp_deck1, _} = Enum.reduce(1..card1, {new_deck(), new_deck1}, fn _, {new_deck, old_deck} ->
            {card, old_deck} = pop_card(old_deck)
            if card do
              {push_card(new_deck, card), old_deck}
            else
              {new_deck, old_deck}
            end
          end)
          {tmp_deck2, _} = Enum.reduce(1..card2, {new_deck(), new_deck2}, fn _, {new_deck, old_deck} ->
            {card, old_deck} = pop_card(old_deck)
            if card do
              {push_card(new_deck, card), old_deck}
            else
              {new_deck, old_deck}
            end
          end)
          case play_recursive_game(tmp_deck1, tmp_deck2) do
            {1, _} ->
              new_deck1 = new_deck1
              |> push_card(card1)
              |> push_card(card2)
              play_recursive_game(new_deck1, new_deck2, new_seen_decks)
            {2, _} ->
              new_deck2 = new_deck2
              |> push_card(card2)
              |> push_card(card1)
              play_recursive_game(new_deck1, new_deck2, new_seen_decks)
          end
        else
          # normal game
          if card1 > card2 do
            new_deck1 = new_deck1
            |> push_card(card1)
            |> push_card(card2)
            play_recursive_game(new_deck1, new_deck2, new_seen_decks)
          else
            new_deck2 = new_deck2
            |> push_card(card2)
            |> push_card(card1)
            play_recursive_game(new_deck1, new_deck2, new_seen_decks)
          end
        end
    end
  end

  def deck_score(deck) do
    deck_to_list(deck)
    |> Enum.reverse
    |> Enum.with_index
    |> Enum.map(fn {value, index} -> value * (index + 1) end)
    |> Enum.sum
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

input = Day22.import("input_day22.txt")

input
|> Day22.task1
|> IO.puts

input
|> Day22.task2
|> IO.puts
