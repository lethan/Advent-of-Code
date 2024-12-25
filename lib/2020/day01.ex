defmodule AoC.Year2020.Day1 do
  @year 2020

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp equals(_value, _product, []), do: nil

  defp equals(value, product, list) do
    List.foldl(list, nil, fn val, result ->
      cond do
        result ->
          result

        true ->
          if val + value == @year do
            product * val
          end
      end
    end)
  end

  def task1(list, current_pair \\ {0, 1})
  def task1([], {_val, _prod} = _pair), do: nil

  def task1([value | tail], {current_value, current_product} = current_pair) do
    result = equals(value + current_value, value * current_product, tail)
    result || task1(tail, current_pair)
  end

  def taks2([]), do: nil

  def task2([value | tail]) do
    result = task1(tail, {value, value})
    result || task2(tail)
  end
end

input = AoC.Year2020.Day1.import("input/2020/input_day01.txt")

input
|> AoC.Year2020.Day1.task1()
|> IO.puts()

input
|> AoC.Year2020.Day1.task2()
|> IO.puts()
