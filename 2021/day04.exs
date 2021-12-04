defmodule Day4 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n", trim: true)
    |> convert_to_data()
  end

  defp convert_to_data(input) do
    [numbers | tickets] = input

    numbers =
      numbers
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    tickets =
      tickets
      |> Enum.map(&new_ticket/1)

    {numbers, tickets}
  end

  defp new_ticket(str) do
    str
    |> String.split("\n")
    |> Enum.map(fn x ->
      x
      |> String.trim()
      |> String.split(~r/\s+/, trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> Enum.reduce({%{}, %{}}, fn {row_data, row}, acc ->
      row_data
      |> Enum.reduce(acc, fn {number, column}, {numbers_on_ticket, positions} ->
        {Map.put(numbers_on_ticket, number, {row, column}),
         Map.put(positions, {row, column}, {number, :unmarked})}
      end)
    end)
  end

  defp find_winning_ticket(numbers, unchecked, checked \\ [])
  defp find_winning_ticket([], _, _), do: "no winner"

  defp find_winning_ticket([_ | numbers], [], checked) do
    find_winning_ticket(numbers, checked)
  end

  defp find_winning_ticket(
         [number | _] = numbers,
         [{numbers_on_ticket, positions} | tickets],
         checked
       )
       when is_map_key(numbers_on_ticket, number) do
    position = Map.fetch!(numbers_on_ticket, number)
    positions = Map.replace!(positions, position, {number, :marked})

    case check_bingo(positions, position) do
      true ->
        {number, {numbers_on_ticket, positions}}

      _ ->
        find_winning_ticket(numbers, tickets, [{numbers_on_ticket, positions} | checked])
    end
  end

  defp find_winning_ticket(numbers, [ticket | tickets], checked) do
    find_winning_ticket(numbers, tickets, [ticket | checked])
  end

  defp check_bingo(
         positions,
         position,
         indexes \\ 0..4 |> Enum.to_list(),
         row_bingo \\ true,
         column_bingo \\ true
       )

  defp check_bingo(_, _, _, false, false), do: false
  defp check_bingo(_, _, [], _, _), do: true

  defp check_bingo(positions, position = {row, column}, [index | tail], row_bingo, column_bingo) do
    check_bingo(
      positions,
      position,
      tail,
      row_bingo && elem(Map.fetch!(positions, {index, column}), 1) == :marked,
      column_bingo && elem(Map.fetch!(positions, {row, index}), 1) == :marked
    )
  end

  defp find_last_winning_ticket(numbers, unchecked, checked \\ [])
  defp find_last_winning_ticket([], _, _), do: "no winner"

  defp find_last_winning_ticket([number | numbers], [{numbers_on_ticket, positions}], [])
       when is_map_key(numbers_on_ticket, number) do
    position = Map.fetch!(numbers_on_ticket, number)
    positions = Map.replace!(positions, position, {number, :marked})

    case check_bingo(positions, position) do
      true ->
        {number, {numbers_on_ticket, positions}}

      _ ->
        find_last_winning_ticket(numbers, [{numbers_on_ticket, positions}], [])
    end
  end

  defp find_last_winning_ticket([_ | numbers], [ticket], []) do
    find_last_winning_ticket(numbers, [ticket], [])
  end

  defp find_last_winning_ticket([_ | numbers], [], checked) do
    find_last_winning_ticket(numbers, checked)
  end

  defp find_last_winning_ticket(
         [number | _] = numbers,
         [{numbers_on_ticket, positions} | tickets],
         checked
       )
       when is_map_key(numbers_on_ticket, number) do
    position = Map.fetch!(numbers_on_ticket, number)
    positions = Map.replace!(positions, position, {number, :marked})

    case check_bingo(positions, position) do
      true ->
        find_last_winning_ticket(numbers, tickets, checked)

      _ ->
        find_last_winning_ticket(numbers, tickets, [{numbers_on_ticket, positions} | checked])
    end
  end

  defp find_last_winning_ticket(numbers, [ticket | tickets], checked) do
    find_last_winning_ticket(numbers, tickets, [ticket | checked])
  end

  def task1({numbers, tickets}) do
    {number, {_numbers_on_ticket, positions}} = find_winning_ticket(numbers, tickets)

    positions
    |> Enum.reduce(0, fn {{_, _}, {value, status}}, acc ->
      case status == :unmarked do
        true ->
          value + acc

        _ ->
          acc
      end
    end)
    |> Kernel.*(number)
  end

  def task2({numbers, tickets}) do
    {number, {_numbers_on_ticket, positions}} = find_last_winning_ticket(numbers, tickets)

    positions
    |> Enum.reduce(0, fn {{_, _}, {value, status}}, acc ->
      case status == :unmarked do
        true ->
          value + acc

        _ ->
          acc
      end
    end)
    |> Kernel.*(number)
  end
end

input = Day4.import("input_day04.txt")

input
|> Day4.task1()
|> IO.puts()

input
|> Day4.task2()
|> IO.puts()
