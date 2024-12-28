defmodule AoC.Year2020.Day21 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      [ingredients, contains] = Regex.run(~r/^([^(]+) \(contains ([^)]+)\)$/, x, capture: :all_but_first)
      {MapSet.new(String.split(ingredients, " ")), String.split(contains, ", ")}
    end)
  end

  defp reduce_translations(map, acc) when map == %{}, do: acc

  defp reduce_translations(map, acc) do
    {contain, ingredients} =
      Enum.find(map, fn {_, ingredients} ->
        MapSet.size(ingredients) == 1
      end)

    new_acc = Map.put(acc, contain, ingredients)

    map
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      Map.put(acc, key, MapSet.difference(value, ingredients))
    end)
    |> Map.delete(contain)
    |> reduce_translations(new_acc)
  end

  defp contains_translation(input) do
    input
    |> Enum.reduce(%{}, fn {ingredients, contains}, acc ->
      Enum.reduce(contains, acc, fn contain, acc2 ->
        Map.update(acc2, contain, ingredients, fn existing_value ->
          MapSet.intersection(existing_value, ingredients)
        end)
      end)
    end)
    |> reduce_translations(%{})
  end

  def task1(input) do
    contains_ingredients =
      input
      |> contains_translation
      |> Enum.reduce(MapSet.new(), fn {_, possible_ingredients}, acc ->
        MapSet.union(acc, possible_ingredients)
      end)

    input
    |> Enum.map(fn {ingredients, _} ->
      MapSet.difference(ingredients, contains_ingredients)
      |> MapSet.size()
    end)
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> contains_translation
    |> Enum.sort(&(elem(&1, 0) <= elem(&2, 0)))
    |> Enum.map(fn {_, ingredient} ->
      MapSet.to_list(ingredient)
    end)
    |> List.flatten()
    |> Enum.join(",")
  end
end

# input = AoC.Year2020.Day21.import("input/2020/input_day21.txt")

# input
# |> AoC.Year2020.Day21.task1()
# |> IO.puts()

# input
# |> AoC.Year2020.Day21.task2()
# |> IO.puts()
