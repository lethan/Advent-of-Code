defmodule AoC.Year2025.Day5 do
  def import(file) do
    {:ok, content} = File.read(file)

    [fresh_ranges, ids] =
      content
      |> String.split("\n\n", trim: true)

    fresh_ranges =
      fresh_ranges
      |> String.split("\n", trim: true)
      |> Enum.map(fn str ->
        [start, finish] =
          str
          |> String.split("-")

        {String.to_integer(start), String.to_integer(finish)}
      end)

    ids =
      ids
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    {fresh_ranges, ids}
  end

  defp fresh_id(_, []), do: :spoiled
  defp fresh_id(id, [{start, finish} | _]) when id >= start and id <= finish, do: :fresh
  defp fresh_id(id, [_ | rest]), do: fresh_id(id, rest)

  defp fresh_ids({fresh_ranges, ids}) do
    ids
    |> Enum.map(&fresh_id(&1, fresh_ranges))
    |> Enum.filter(&(&1 == :fresh))
    |> Enum.count()
  end

  defp merge_ranges(fresh_ranges) do
    fresh_ranges
    |> Enum.reduce([], fn range, acc ->
      merge_range(range, acc)
    end)
  end

  defp merge_range(range, ranges, result \\ [])
  defp merge_range(range, [], result), do: [range | result]

  defp merge_range({start_a, finish_a}, [{start_b, finish_b} | rest], result)
       when (start_a >= start_b and start_a <= finish_b) or (start_b >= start_a and start_b <= finish_a) do
    merge_range({min(start_a, start_b), max(finish_a, finish_b)}, rest, result)
  end

  defp merge_range(range, [a | rest], result), do: merge_range(range, rest, [a | result])

  def task1(input) do
    input
    |> fresh_ids()
  end

  def task2(input) do
    input
    |> elem(0)
    |> merge_ranges()
    |> Enum.reduce(0, fn {start, finish}, acc ->
      acc + finish - start + 1
    end)
  end
end

# input = AoC.Year2025.Day5.import("input/2025/input_day05.txt")

# input
# |> AoC.Year2025.Day5.task1()
# |> IO.puts()

# input
# |> AoC.Year2025.Day5.task2()
# |> IO.puts()
