defmodule Day14 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n", trim: true)
    |> convert_to_data()
  end

  defp convert_to_data(input) do
    [template, rules] = input

    template =
      template
      |> String.graphemes()

    rules =
      rules
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn string, acc ->
        [input, result] = String.split(string, " -> ")

        input = String.graphemes(input) |> List.to_tuple()
        Map.put(acc, input, result)
      end)

    {template, rules}
  end

  defp added_in_steps(0, _a, _b, _rules, cache), do: {%{}, cache}

  defp added_in_steps(n, a, b, _rules, cache) when is_map_key(cache, {{a, b}, n}) do
    {Map.get(cache, {{a, b}, n}), cache}
  end

  defp added_in_steps(n, a, b, rules, cache) do
    middle = Map.fetch!(rules, {a, b})
    {first_added, new_cache} = added_in_steps(n - 1, a, middle, rules, cache)
    {last_added, new_cache} = added_in_steps(n - 1, middle, b, rules, new_cache)

    result =
      %{middle => 1}
      |> Map.merge(first_added, fn _k, v1, v2 -> v1 + v2 end)
      |> Map.merge(last_added, fn _k, v1, v2 -> v1 + v2 end)

    new_cache = Map.put(new_cache, {{a, b}, n}, result)

    {result, new_cache}
  end

  defp distribution_steps([], _steps, _rules), do: %{}

  defp distribution_steps(list, steps, rules) do
    [first | rest] = list

    {_, result, _} =
      Enum.reduce(
        rest,
        {first, %{first => 1}, %{}},
        fn current, {prev, current_result, current_cache} ->
          {result, new_cache} = added_in_steps(steps, prev, current, rules, current_cache)

          result =
            %{current => 1}
            |> Map.merge(current_result, fn _k, v1, v2 -> v1 + v2 end)
            |> Map.merge(result, fn _k, v1, v2 -> v1 + v2 end)

          {current, result, new_cache}
        end
      )

    result
  end

  def task1(input) do
    {template, rules} = input

    {min, max} =
      distribution_steps(template, 10, rules)
      |> Enum.min_max_by(fn {_key, value} -> value end)

    elem(max, 1) - elem(min, 1)
  end

  def task2(input) do
    {template, rules} = input

    {min, max} =
      distribution_steps(template, 40, rules)
      |> Enum.min_max_by(fn {_key, value} -> value end)

    elem(max, 1) - elem(min, 1)
  end
end

input = Day14.import("input_day14.txt")

input
|> Day14.task1()
|> IO.puts()

input
|> Day14.task2()
|> IO.puts()
