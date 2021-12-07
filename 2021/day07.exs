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

  defp minimum_fuel_usage(input, cost) do
    {min, max} =
      input
      |> Enum.min_max()

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
    {min, max} =
      input
      |> Enum.min_max()

    cost =
      (min - min)..(max - min)
      |> Enum.into(%{}, fn x -> {x, x} end)

    minimum_fuel_usage(input, cost)
  end

  def task2(input) do
    cost =
      input
      |> fuel_cost

    minimum_fuel_usage(input, cost)
  end
end

input = Day7.import("input_day07.txt")

input
|> Day7.task1()
|> IO.puts()

input
|> Day7.task2()
|> IO.puts()
