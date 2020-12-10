defmodule Day10 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort
  end

  defp chunk_at_three_steps(current_value, []), do: {:cont, [current_value]}
  defp chunk_at_three_steps(current_value, [last_value | _] = acc) do
    if current_value - last_value == 3 do
      {:cont, Enum.reverse(acc), [current_value]}
    else
      {:cont, [current_value | acc]}
    end
  end

  defp after_chunk_at_three_steps([]), do: {:cont, []}
  defp after_chunk_at_three_steps(acc), do: {:cont, Enum.reverse(acc), []}

  defp permutations([element | []], acc), do: [[element | acc]]
  defp permutations([element | rest], []), do: permutations(rest, [element])
  defp permutations([element | rest], acc) do
    permutations(rest, acc) ++
    permutations(rest, [element | acc])
  end

  defp valid_permutation?([first | rest = [second | _]]) do
    if first - second <= 3 do
      valid_permutation?(rest)
    else
      false
    end
  end
  defp valid_permutation?(_), do: true

  def task1(input) do
    {diffs, _} = input
    |> Enum.reduce({%{3 => 1}, 0}, fn x, {diffs, last_value} ->
      {Map.update(diffs, x - last_value, 1, &(&1 + 1)), x}
    end)

    Map.get(diffs, 1, 0) * Map.get(diffs, 3, 0)
  end

  def task2(input) do
    [0 | input]
    |> Enum.chunk_while([], &chunk_at_three_steps/2, &after_chunk_at_three_steps/1)
    |> Enum.map(&permutations(&1, []))
    |> Enum.map(&Enum.filter(&1, fn x -> valid_permutation?(x) end))
    |> Enum.map(&Enum.count/1)
    |> Enum.reduce(&(&1 * &2))
  end
end

input = Day10.import("input_day10.txt")

input
|> Day10.task1
|> IO.puts

input
|> Day10.task2
|> IO.puts
