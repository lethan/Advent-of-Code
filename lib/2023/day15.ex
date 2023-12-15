defmodule AoC.Year2023.Day15 do
  def import(file) do
    content = File.read!(file)

    content
    |> String.trim()
    |> String.split(",")
  end

  defp hash(value, ""), do: value

  defp hash(value, <<head::integer, rest::binary>>) do
    value
    |> Kernel.+(head)
    |> Kernel.*(17)
    |> rem(256)
    |> hash(rest)
  end

  defp remove_lens(_lens, [], result), do: Enum.reverse(result)

  defp remove_lens(lens, [{lens, _} | rest], result) do
    Enum.reverse(result) ++ rest
  end

  defp remove_lens(lens, [a | rest], result), do: remove_lens(lens, rest, [a | result])

  defp add_or_update_lens(lens, value, [], result), do: [{lens, value} | Enum.reverse(result)]

  defp add_or_update_lens(lens, value, [{lens, _} | rest], result) do
    Enum.reverse(result) ++ [{lens, value} | rest]
  end

  defp add_or_update_lens(lens, value, [a | rest], result) do
    add_or_update_lens(lens, value, rest, [a | result])
  end

  defp split_operation("=" <> rest, operation) do
    {:add, operation, String.to_integer(rest)}
  end

  defp split_operation("-", operation) do
    {:delete, operation}
  end

  defp split_operation(<<c::binary-1, rest::binary>>, operation), do: split_operation(rest, operation <> c)

  defp update_box(boxes, operation) do
    case split_operation(operation, "") do
      {:delete, lens} ->
        box = hash(0, lens)
        list = Map.get(boxes, box, [])
        Map.put(boxes, box, remove_lens(lens, list, []))

      {:add, lens, value} ->
        box = hash(0, lens)
        list = Map.get(boxes, box, [])
        Map.put(boxes, box, add_or_update_lens(lens, value, list, []))
    end
  end

  defp focusing_power(boxes) do
    boxes
    |> Enum.reduce(0, fn {box, list}, acc ->
      list
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {{_, value}, index}, acc ->
        acc + (box + 1) * (index + 1) * value
      end)
    end)
  end

  def task1(input) do
    input
    |> Enum.reduce(0, fn str, acc ->
      acc + hash(0, str)
    end)
  end

  def task2(input) do
    input
    |> Enum.reduce(%{}, fn operation, acc ->
      update_box(acc, operation)
    end)
    |> focusing_power()
  end
end

# input = AoC.Year2023.Day15.import("input/2023/input_day15.txt")

# input
# |> AoC.Year2023.Day15.task1()
# |> IO.puts()

# input
# |> AoC.Year2023.Day15.task2()
# |> IO.puts()
