defmodule AoC.Year2025.Day7 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {str, row}, acc ->
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, column}, acc2 ->
        type =
          case char do
            "." -> :empty
            "S" -> :manifold
            "^" -> :splitter
          end

        Map.put(acc2, {column, row}, type)
      end)
    end)
  end

  defp splits(map) do
    {x, y} =
      map
      |> Enum.find(fn {_, val} -> val == :manifold end)
      |> elem(0)

    splits([{x, y + 1}], map, 0)
  end

  defp splits([], _, splits), do: splits

  defp splits([coord = {x, y} | rest], map, splits) do
    case Map.get(map, coord) do
      :empty ->
        map = Map.put(map, coord, :beam)
        splits([{x, y + 1} | rest], map, splits)

      :splitter ->
        map = Map.put(map, coord, :used_splitter)
        splits([{x + 1, y}, {x - 1, y} | rest], map, splits + 1)

      _ ->
        splits(rest, map, splits)
    end
  end

  defp timelines(map) do
    {x, y} =
      map
      |> Enum.find(fn {_, val} -> val == :manifold end)
      |> elem(0)

    timelines({x, y + 1}, map)
    |> elem(0)
  end

  defp timelines(coord = {x, y}, map) do
    case Map.get(map, coord) do
      :empty ->
        map = Map.put(map, coord, :beam)
        timelines({x, y + 1}, map)

      :beam ->
        timelines({x, y + 1}, map)

      {:splitter, times} ->
        {times, map}

      :splitter ->
        {times1, map} = timelines({x - 1, y}, map)
        {times2, map} = timelines({x + 1, y}, map)
        map = Map.put(map, coord, {:splitter, times1 + times2})
        {times1 + times2, map}

      nil ->
        {1, map}
    end
  end

  def task1(input) do
    input
    |> splits()
  end

  def task2(input) do
    input
    |> timelines()
  end
end

# input = AoC.Year2025.Day7.import("input/2025/input_day07.txt")

# input
# |> AoC.Year2025.Day7.task1()
# |> IO.puts()

# input
# |> AoC.Year2025.Day7.task2()
# |> IO.puts()
