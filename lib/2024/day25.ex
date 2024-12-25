defmodule AoC.Year2024.Day25 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n", trim: true)
    |> Enum.reduce({[], []}, fn str, {locks, keys} ->
      str
      |> String.split("\n", trim: true)
      |> case do
        ["#####" | rest] ->
          heights = List.duplicate(0, 5)

          lock =
            rest
            |> Enum.reduce(heights, fn s, heights ->
              s
              |> String.graphemes()
              |> Enum.map(fn v -> if v == "#", do: 1, else: 0 end)
              |> (fn values -> [values, heights] end).()
              |> Enum.zip_with(fn [a, b] -> a + b end)
            end)

          {[lock | locks], keys}

        ["....." | rest] ->
          heights = List.duplicate(-1, 5)

          key =
            rest
            |> Enum.reduce(heights, fn s, heights ->
              s
              |> String.graphemes()
              |> Enum.map(fn v -> if v == "#", do: 1, else: 0 end)
              |> (fn values -> [values, heights] end).()
              |> Enum.zip_with(fn [a, b] -> a + b end)
            end)

          {locks, [key | keys]}
      end
    end)
  end

  defp possible_pairs({locks, keys}) do
    locks
    |> Enum.reduce(0, fn lock, result ->
      keys
      |> Enum.reduce(result, fn key, acc ->
        spaces = Enum.zip_with([lock, key], fn [a, b] -> a + b end)
        if Enum.any?(spaces, fn v -> v > 5 end), do: acc, else: acc + 1
      end)
    end)
  end

  def task1(input) do
    input
    |> possible_pairs()
  end
end

# input = AoC.Year2024.Day25.import("input/2024/input_day25.txt")

# input
# |> AoC.Year2024.Day25.task1()
# |> IO.puts()
