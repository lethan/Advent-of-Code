defmodule Day19 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_rules_and_messages
  end

  defp parse_rule(string) do
    string
    |> String.split(" | ")
    |> Enum.map(fn str ->
      String.split(str, " ")
      |> Enum.map(fn x -> if String.match?(x, ~r/"([a-z]+)"/) do String.slice(x, 1..-2) else String.to_integer(x) end end)
    end)
  end

  defp convert_to_rules_and_messages(list) do
    list
    |> Enum.reduce({%{}, []}, fn string, {rules, messages} ->
      cond do
        String.match?(string, ~r/^[0-9]+: .+$/) ->
          [rule_number, rest] = String.split(string, ": ")
          new_rules = parse_rule(rest)
          {Map.put(rules, String.to_integer(rule_number), new_rules), messages}
        true ->
          {rules, [string | messages]}
      end
    end)
  end

  def expand(string, _) when is_bitstring(string), do: [[string]]
  def expand(number, rules) when is_integer(number) do
    Map.get(rules, number)
    |> Enum.map(fn list ->
      Enum.map(list, fn x ->
        fn -> expand(x, rules) end
      end)
    end)
  end

  def match("", []), do: true
  def match(_, []), do: false
  def match(string, [first | rest]) when is_bitstring(first) do
    if String.first(string) == first do
      match(String.slice(string, 1..-1), rest)
    else
      false
    end
  end
  def match(string, [first | rest]) when is_function(first, 0) do
    first.()
    |> Enum.reduce(false, fn list, acc ->
      acc or match(string, list ++ rest)
    end)
  end

  def task1(input) do
    {rules, messages} = input

    start = [fn -> Day19.expand(0, rules) end]

    messages
    |> Enum.filter(fn x -> match(x, start) end)
    |> Enum.count
  end

  def task2(input) do
    {rules, messages} = input

    rules = rules
    |> Map.put(8, parse_rule("42 | 42 8"))
    |> Map.put(11, parse_rule("42 31 | 42 11 31"))

    start = [fn -> Day19.expand(0, rules) end]

    messages
    |> Enum.filter(fn x -> match(x, start) end)
    |> Enum.count
  end
end

input = Day19.import("input_day19.txt")

input
|> Day19.task1
|> IO.puts

input
|> Day19.task2
|> IO.puts
