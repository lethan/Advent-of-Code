defmodule Day7 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp fuel_cost(input) do
    {min, max} =
      input
      |> Enum.min_max()

    (min - min)..(max - min)
    |> Enum.reduce({%{}, 0, 0}, fn x, {map, step, prev} ->
      {Map.put(map, x, prev + step), step + 1, prev + step}
    end)
    |> elem(0)
  end

  defp fuel_usage(frequencies, fuel_cost, destination) do
    frequencies
    |> Enum.reduce(0, fn {position, count}, acc ->
      acc + Map.fetch!(fuel_cost, abs(position - destination)) * count
    end)
  end

  defp minimum_fuel_usage(input) do
    {min, max} =
      input
      |> Enum.min_max()

    cost =
      input
      |> fuel_cost()

    frequencies =
      input
      |> Enum.frequencies()

    min..max
    |> Enum.map(fn destination ->
      fuel_usage(frequencies, cost, destination)
    end)
    |> Enum.min()
  end

  def task1(input) do
    median =
      input
      |> Enum.sort()
      |> Enum.at(div(Enum.count(input), 2))

    input
    |> Enum.frequencies()
    |> Enum.reduce(0, fn {position, count}, acc ->
      acc + abs(position - median) * count
    end)
  end

  def task2(input), do: minimum_fuel_usage(input)
end

input = Day7.import("input_day07.txt")

input
|> Day7.task1()
|> IO.puts()

input
|> Day7.task2()
|> IO.puts()
