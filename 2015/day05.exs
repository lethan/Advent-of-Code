defmodule AOC2015.Day5 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp vovels([]), do: 0

  defp vovels([char | rest]) when char in ["a", "e", "i", "o", "u"], do: 1 + vovels(rest)

  defp vovels([_ | rest]), do: vovels(rest)

  defp valid_string(list, found_duplidate \\ false)
  defp valid_string([], found_duplidate), do: found_duplidate
  defp valid_string([_], found_duplidate), do: found_duplidate
  defp valid_string(["a", "b" | _], _), do: false
  defp valid_string(["c", "d" | _], _), do: false
  defp valid_string(["p", "q" | _], _), do: false
  defp valid_string(["x", "y" | _], _), do: false

  defp valid_string([a, b | rest], _) when a == b do
    valid_string([b | rest], true)
  end

  defp valid_string([_, b | rest], found_duplidate) do
    valid_string([b | rest], found_duplidate)
  end

  defp nice_string(list, seen_pairs \\ %{}, found_pair \\ false, found_repeat \\ false)
  defp nice_string(_, _, true, true), do: true

  defp nice_string([a, a, a | rest], seen_pairs, found_pair, _found_repeat) do
    nice_string(
      [a | rest],
      Map.put(seen_pairs, {a, a}, true),
      found_pair or Map.get(seen_pairs, {a, a}, false),
      true
    )
  end

  defp nice_string([a, b, a | rest], seen_pairs, found_pair, _found_repeat) do
    nice_string(
      [b, a | rest],
      Map.put(seen_pairs, {a, b}, true),
      found_pair or Map.get(seen_pairs, {a, b}, false),
      true
    )
  end

  defp nice_string([a, b, c | rest], seen_pairs, found_pair, found_repeat) do
    nice_string(
      [b, c | rest],
      Map.put(seen_pairs, {a, b}, true),
      found_pair or Map.get(seen_pairs, {a, b}, false),
      found_repeat
    )
  end

  defp nice_string([a, b], seen_pairs, found_pair, found_repeat) do
    nice_string(
      [b],
      Map.put(seen_pairs, {a, b}, true),
      found_pair or Map.get(seen_pairs, {a, b}, false),
      found_repeat
    )
  end

  defp nice_string(_, _, _, _), do: false

  def task1(input) do
    input
    |> Enum.filter(fn x ->
      vovels(x) >= 3 and valid_string(x)
    end)
    |> Enum.count()
  end

  def task2(input) do
    input
    |> Enum.filter(&nice_string/1)
    |> Enum.count()
  end
end

input = AOC2015.Day5.import("input_day05.txt")

input
|> AOC2015.Day5.task1()
|> IO.puts()

input
|> AOC2015.Day5.task2()
|> IO.puts()
