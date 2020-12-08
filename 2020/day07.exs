defmodule Day7 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&split_to_pair/1)
  end

  defp split_to_pair(string) do
    [current_bag, rest] = String.split(string, " bags contain ")
    bags = Regex.scan(~r/([0-9]+) ([^.,]+) bags?[.,]/, rest, capture: :all_but_first)
    |> Enum.map(fn [count, bag] -> {bag, String.to_integer(count)} end)
    {current_bag, bags}
  end

  defp build_contained_in_tree(tree, current_bag, contained_in) do
    {_, tree} = Map.get_and_update(tree, contained_in, fn current_value ->
      {current_value, if current_value do
        MapSet.put(current_value, current_bag)
      else
        MapSet.new([current_bag])
      end}
    end)
    tree
  end

  defp contained_in(tree, current_bag, visited) do
    Enum.reduce(Map.get(tree, current_bag, MapSet.new), visited, fn x, acc ->
      if Map.get(acc, x) == nil do
        contained_in(tree, x, MapSet.put(acc, x))
      else
        acc
      end
    end)
  end

  defp number_bags_in(tree, current_bag, mulitplier \\ 1) do
    Enum.sum(Enum.map(tree[current_bag], fn {bag, amount} -> mulitplier * amount + number_bags_in(tree, bag, mulitplier * amount) end))
  end

  def task1(input) do
    input
    |> Enum.reduce(%{}, fn {current_bag, list_contained_in}, accumlator ->
      Enum.reduce(list_contained_in, accumlator, fn {bag, _count}, acc ->
        build_contained_in_tree(acc, current_bag, bag)
      end)
    end)
    |> contained_in("shiny gold", MapSet.new)
    |> MapSet.size
  end

  def task2(input) do
    input
    |> Enum.reduce(%{}, fn {bag, contains}, acc -> Map.put(acc, bag, contains) end)
    |> number_bags_in("shiny gold")
  end
end

input = Day7.import("input_day07.txt")

input
|> Day7.task1
|> IO.puts

input
|> Day7.task2
|> IO.puts
