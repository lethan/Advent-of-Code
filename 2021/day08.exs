defmodule Day8 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&convert_to_data/1)
  end

  defp convert_to_data(input) do
    [segments, output] =
      input
      |> String.split(" | ")

    segments =
      segments
      |> String.split(" ")
      |> Enum.map(fn x ->
        x
        |> String.graphemes()
        |> MapSet.new()
      end)

    output =
      output
      |> String.split(" ")
      |> Enum.map(fn x ->
        x
        |> String.graphemes()
        |> MapSet.new()
      end)

    {segments, output}
  end

  defp get_translation(segments) do
    segments_by_size =
      segments
      |> Enum.group_by(&MapSet.size/1)

    digit_1 = List.first(Map.fetch!(segments_by_size, 2))
    digit_7 = List.first(Map.fetch!(segments_by_size, 3))
    digit_4 = List.first(Map.fetch!(segments_by_size, 4))
    digit_8 = List.first(Map.fetch!(segments_by_size, 7))

    segment_a = MapSet.difference(digit_7, digit_1)

    almost_9 = MapSet.union(digit_4, segment_a)

    digit_9 =
      Map.fetch!(segments_by_size, 6)
      |> Enum.find(fn x ->
        MapSet.subset?(almost_9, x)
      end)

    digit_6 =
      Map.fetch!(segments_by_size, 6)
      |> Enum.find(fn x ->
        not MapSet.subset?(digit_1, x)
      end)

    digit_0 =
      Map.fetch!(segments_by_size, 6)
      |> Enum.find(fn x ->
        x not in [digit_6, digit_9]
      end)

    digit_5 =
      Map.fetch!(segments_by_size, 5)
      |> Enum.find(fn x ->
        MapSet.subset?(x, digit_6)
      end)

    segment_e = MapSet.difference(digit_6, digit_5)

    digit_2 =
      Map.fetch!(segments_by_size, 5)
      |> Enum.find(fn x ->
        MapSet.subset?(segment_e, x)
      end)

    digit_3 =
      Map.fetch!(segments_by_size, 5)
      |> Enum.find(fn x ->
        x not in [digit_2, digit_5]
      end)

    %{
      digit_0 => 0,
      digit_1 => 1,
      digit_2 => 2,
      digit_3 => 3,
      digit_4 => 4,
      digit_5 => 5,
      digit_6 => 6,
      digit_7 => 7,
      digit_8 => 8,
      digit_9 => 9
    }
  end

  defp value_segments(list, translation), do: value_segments(Enum.reverse(list), translation, 1)

  defp value_segments([], _translation, _multiplier), do: 0

  defp value_segments([segments | rest], translation, multiplier) do
    multiplier * Map.fetch!(translation, segments) +
      value_segments(rest, translation, multiplier * 10)
  end

  def task1(input) do
    input
    |> Enum.reduce(0, fn {_, output}, acc ->
      output
      |> Enum.map(&MapSet.size/1)
      |> Enum.reduce(acc, fn size, acc2 ->
        if Enum.member?([2, 3, 4, 7], size), do: acc2 + 1, else: acc2
      end)
    end)
  end

  def task2(input) do
    input
    |> Enum.reduce(0, fn {segments, output}, acc ->
      acc + value_segments(output, get_translation(segments))
    end)
  end
end

input = Day8.import("input_day08.txt")

input
|> Day8.task1()
|> IO.puts()

input
|> Day8.task2()
|> IO.puts()
