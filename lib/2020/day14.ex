defmodule AoC.Year2020.Day14 do
  import Bitwise

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.chunk_while(nil, &split_to_mask_groups/2, &after_split/1)
  end

  defp split_to_mask_groups(current_value, acc) do
    cond do
      String.match?(current_value, ~r/mask = ([01X]+)/) ->
        [mask] = Regex.run(~r/mask = ([01X]+)/, current_value, capture: :all_but_first)

        if acc do
          {last_mask, list} = acc
          {:cont, {last_mask, Enum.reverse(list)}, {mask, []}}
        else
          {:cont, {mask, []}}
        end

      String.match?(current_value, ~r/mem\[([0-9]+)\] = ([0-9]+)/) ->
        [address, value] = Regex.run(~r/mem\[([0-9]+)\] = ([0-9]+)/, current_value, capture: :all_but_first)
        {mask, list} = acc
        {:cont, {mask, [{String.to_integer(address), String.to_integer(value)} | list]}}
    end
  end

  defp after_split({mask, list}), do: {:cont, {mask, Enum.reverse(list)}, nil}

  defp bitvalues(mask) do
    {_, or_op, and_op} =
      mask
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.reduce({1, 0, 0}, fn value, {multiplier, or_op, and_op} ->
        {multiplier <<< 1,
         or_op +
           if value != "1" do
             0
           else
             multiplier
           end,
         and_op +
           if value == "0" do
             0
           else
             multiplier
           end}
      end)

    {or_op, and_op}
  end

  defp bitvalues2(mask) do
    {_, or_op, and_op, floating} =
      mask
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.reduce({1, 0, 0, []}, fn value, {multiplier, or_op, and_op, floating} ->
        {multiplier <<< 1,
         or_op +
           if value == "1" do
             multiplier
           else
             0
           end,
         and_op +
           if value != "X" do
             multiplier
           else
             0
           end,
         if value == "X" do
           [multiplier | floating]
         else
           floating
         end}
      end)

    floating
    |> Enum.reduce([0], &list_of_masks(&2, &1))
    |> Enum.map(&{&1 + or_op, &1 + and_op})
  end

  defp list_of_masks([], _), do: []

  defp list_of_masks([first | rest], value) do
    [first | [first + value | list_of_masks(rest, value)]]
  end

  def task1(input) do
    input
    |> Enum.reduce(%{}, fn {mask, list}, acc ->
      {or_op, and_op} = bitvalues(mask)

      Enum.reduce(list, acc, fn {address, value}, acc2 ->
        Map.put(acc2, address, (value &&& and_op) ||| or_op)
      end)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.reduce(%{}, fn {mask, list}, acc ->
      mask_list = bitvalues2(mask)

      Enum.reduce(list, acc, fn {address, value}, acc2 ->
        Enum.reduce(mask_list, acc2, fn {or_op, and_op}, acc3 ->
          Map.put(acc3, (address &&& and_op) ||| or_op, value)
        end)
      end)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end
end

# input = AoC.Year2020.Day14.import("input/2020/input_day14.txt")

# input
# |> AoC.Year2020.Day14.task1()
# |> IO.puts()

# input
# |> AoC.Year2020.Day14.task2()
# |> IO.puts()
