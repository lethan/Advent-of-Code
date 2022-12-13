defmodule AOC2022.Day13 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n", trim: true)
    |> Enum.map(&convert_to_data/1)
  end

  def convert_to_data(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_packet/1)
    |> List.to_tuple()
  end

  def parse_packet("[" <> rest) do
    {value, ""} = parse_subpacket(rest, [], "")
    value
  end

  def parse_subpacket("]" <> rest, current_value, "") do
    {Enum.reverse(current_value), rest}
  end

  def parse_subpacket("]" <> rest, current_value, carryover) do
    current_value = [String.to_integer(carryover) | current_value]
    {Enum.reverse(current_value), rest}
  end

  def parse_subpacket("[" <> rest, current_value, "") do
    {value, rest} = parse_subpacket(rest, [], "")
    parse_subpacket(rest, [value | current_value], "")
  end

  def parse_subpacket("," <> rest, current_value, "") do
    parse_subpacket(rest, current_value, "")
  end

  def parse_subpacket("," <> rest, current_value, carryover) do
    current_value = [String.to_integer(carryover) | current_value]
    parse_subpacket(rest, current_value, "")
  end

  def parse_subpacket(<<intchar::binary-1>> <> rest, current_value, carryover) do
    parse_subpacket(rest, current_value, carryover <> intchar)
  end

  def check_order([], []), do: :unknown
  def check_order([], [_ | _]), do: true
  def check_order([_ | _], []), do: false

  def check_order([x | xs], [y | ys]) when is_integer(x) and is_integer(y) do
    case x == y do
      true ->
        check_order(xs, ys)

      false ->
        x < y
    end
  end

  def check_order([x | xs], [y | ys]) do
    case check_order(List.wrap(x), List.wrap(y)) do
      :unknown ->
        check_order(xs, ys)

      value ->
        value
    end
  end

  def task1(input) do
    input
    |> Enum.with_index(1)
    |> Enum.filter(fn {{x, y}, _} -> check_order(x, y) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.reduce([[[2]], [[6]]], fn {x, y}, acc ->
      [x, y | acc]
    end)
    |> Enum.sort(&check_order/2)
    |> Enum.with_index(1)
    |> Enum.filter(fn {packet, _} -> packet in [[[2]], [[6]]] end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.product()
  end
end

input = AOC2022.Day13.import("input_day13.txt")

input
|> AOC2022.Day13.task1()
|> IO.puts()

input
|> AOC2022.Day13.task2()
|> IO.puts()
