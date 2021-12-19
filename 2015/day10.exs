defmodule AOC2015.Day10 do
  def convert_to_data(number) do
    [first | rest] = Integer.digits(number)

    rest
    |> Enum.chunk_while({1, first}, &convert_chunk_before/2, &chunk_after/1)
  end

  defp convert_chunk_before(element, acc = {count, value}) do
    if element == value do
      {:cont, {count + 1, value}}
    else
      {:cont, acc, {1, element}}
    end
  end

  defp chunk_after(:first), do: {:cont, :first}
  defp chunk_after(acc), do: {:cont, acc, acc}

  def apply_step(input) do
    input
    |> Enum.reduce([], fn {count, value}, acc ->
      [{1, value}, {1, count} | acc]
    end)
    |> Enum.reverse()
    |> Enum.chunk_while(:first, &apply_chunk_before/2, &chunk_after/1)
  end

  defp apply_chunk_before(pair, :first) do
    {:cont, pair}
  end

  defp apply_chunk_before(pair = {current_count, current_value}, acc = {acc_count, acc_value}) do
    if current_value == acc_value do
      {:cont, {acc_count + current_count, acc_value}}
    else
      {:cont, acc, pair}
    end
  end

  def size(input) do
    input
    |> Enum.reduce(0, fn {count, _}, acc ->
      count + acc
    end)
  end

  def print(input) do
    input
    |> Enum.map(fn {count, value} ->
      List.duplicate(value, count)
      |> Enum.join()
      |> IO.write()
    end)

    IO.puts("")
  end

  def part1(input) do
    1..40
    |> Enum.reduce(input, fn _, acc ->
      apply_step(acc)
    end)
    |> size()
  end

  def part2(input) do
    1..50
    |> Enum.reduce(input, fn _, acc ->
      apply_step(acc)
    end)
    |> size()
  end
end

input = AOC2015.Day10.convert_to_data(1_113_222_113)

input
|> AOC2015.Day10.part1()
|> IO.puts()

input
|> AOC2015.Day10.part2()
|> IO.puts()
