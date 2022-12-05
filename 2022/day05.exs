defmodule AOC2022.Day5 do
  def import(file) do
    {:ok, content} = File.read(file)

    [stacks, moves] =
      content
      |> String.split("\n\n", trim: true)

    {convert_to_stacks(stacks), convert_to_moves(moves)}
  end

  defp convert_to_stacks(stacks) do
    stacks
    |> String.split("\n")
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn row, acc ->
      row
      |> Stream.unfold(&String.split_at(&1, 4))
      |> Enum.take_while(&(&1 != ""))
      |> Enum.with_index(1)
      |> Enum.reduce(acc, fn {current, stack}, acc2 ->
        trimmed = String.trim(current)

        case trimmed do
          "[" <> <<box::binary-1>> <> "]" ->
            Map.update(acc2, stack, [box], fn val -> [box | val] end)

          _ ->
            acc2
        end
      end)
    end)
  end

  defp convert_to_moves(moves) do
    moves
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      [_, moves, _, from, _, to] =
        str
        |> String.split(" ")

      [moves, from, to] =
        [moves, from, to]
        |> Enum.map(&String.to_integer/1)

      {from, to, moves}
    end)
  end

  def move(stacks, _from, _to, 0), do: stacks

  def move(stacks, from, to, moves) do
    {box, stacks} =
      Map.get_and_update(stacks, from, fn [val | rest] ->
        {val, rest}
      end)

    move(Map.update(stacks, to, [box], fn current -> [box | current] end), from, to, moves - 1)
  end

  def move_advanced(stacks, from, to, moves) do
    {boxes, stacks} =
      Map.get_and_update(stacks, from, fn list ->
        Enum.split(list, moves)
      end)

    Map.update(stacks, to, boxes, fn current -> boxes ++ current end)
  end

  def top_stacks(stacks) do
    Map.keys(stacks)
    |> Enum.sort()
    |> Enum.map(fn key ->
      {:ok, [val | _]} = Map.fetch(stacks, key)
      val
    end)
    |> Enum.join()
  end

  def task1(input) do
    {stacks, moves} = input

    moves
    |> Enum.reduce(stacks, fn {from, to, moves}, acc ->
      move(acc, from, to, moves)
    end)
    |> top_stacks()
  end

  def task2(input) do
    {stacks, moves} = input

    moves
    |> Enum.reduce(stacks, fn {from, to, moves}, acc ->
      move_advanced(acc, from, to, moves)
    end)
    |> top_stacks()
  end
end

input = AOC2022.Day5.import("input_day05.txt")

input
|> AOC2022.Day5.task1()
|> IO.puts()

input
|> AOC2022.Day5.task2()
|> IO.puts()
