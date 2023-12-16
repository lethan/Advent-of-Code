defmodule AoC.Year2023.Day13 do
  def import(file) do
    content = File.read!(file)

    content
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {str, row}, acc ->
        str
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {s, column}, acc ->
          Map.put(acc, {column, row}, s)
        end)
      end)
    end)
  end

  defp chunk_after({acc, row}), do: {:cont, Enum.reverse(acc), {[], row + 1}}

  defp rows(map) do
    map
    |> Enum.sort(fn {{x1, y1}, _}, {{x2, y2}, _} ->
      cond do
        y1 < y2 ->
          true

        y1 > y2 ->
          false

        x1 < x2 ->
          true

        true ->
          false
      end
    end)
    |> Enum.chunk_while(
      {[], nil},
      fn {{_, y}, v}, {acc, current_line} ->
        cond do
          is_nil(current_line) -> {:cont, {[v], y}}
          current_line == y -> {:cont, {[v | acc], current_line}}
          true -> {:cont, Enum.reverse(acc), {[v], y}}
        end
      end,
      &chunk_after/1
    )
    |> Enum.map(&Enum.join/1)
  end

  defp columns(map) do
    map
    |> Enum.sort(fn {{x1, y1}, _}, {{x2, y2}, _} ->
      cond do
        x1 < x2 ->
          true

        x1 > x2 ->
          false

        y1 < y2 ->
          true

        true ->
          false
      end
    end)
    |> Enum.chunk_while(
      {[], nil},
      fn {{x, _}, v}, {acc, current_column} ->
        cond do
          is_nil(current_column) -> {:cont, {[v], x}}
          current_column == x -> {:cont, {[v | acc], current_column}}
          true -> {:cont, Enum.reverse(acc), {[v], x}}
        end
      end,
      &chunk_after/1
    )
    |> Enum.map(&Enum.join/1)
  end

  defp mirror([a | as]) do
    mirror(as, [a], 0)
  end

  defp mirror([], _, result), do: result

  defp mirror([a | as], [a | bs], result) do
    result = result + if equal(as, bs), do: length(bs) + 1, else: 0
    mirror(as, [a, a | bs], result)
  end

  defp mirror([a | as], bs, result), do: mirror(as, [a | bs], result)

  defp equal([], _), do: true
  defp equal(_, []), do: true
  defp equal([a | as], [a | bs]), do: equal(as, bs)
  defp equal(_, _), do: false

  defp diff(a, b) do
    [a, b]
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.reduce(0, fn {a, b}, acc ->
      acc + if a == b, do: 0, else: 1
    end)
  end

  defp smudge_diff([], _, diff), do: diff
  defp smudge_diff(_, [], diff), do: diff

  defp smudge_diff([a | as], [b | bs], diff) do
    smudge_diff(as, bs, diff(a, b) + diff)
  end

  defp smudge_mirror([a | as]) do
    smudge_mirror(as, [a], 0)
  end

  defp smudge_mirror([], _, result), do: result

  defp smudge_mirror([a | as], bs, result) do
    if smudge_diff([a | as], bs, 0) == 1 do
      smudge_mirror(as, [a | bs], result + length(bs))
    else
      smudge_mirror(as, [a | bs], result)
    end
  end

  def task1(input) do
    input
    |> Enum.map(fn cave ->
      columns = columns(cave)
      value = mirror(columns)

      rows = rows(cave)
      value + 100 * mirror(rows)
    end)
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.map(fn cave ->
      columns = columns(cave)
      value = smudge_mirror(columns)

      rows = rows(cave)
      value + 100 * smudge_mirror(rows)
    end)
    |> Enum.sum()
  end
end

# input = AoC.Year2023.Day13.import("input/2023/input_day13.txt")

# input
# |> AoC.Year2023.Day13.task1()
# |> IO.puts()

# input
# |> AoC.Year2023.Day13.task2()
# |> IO.puts()
