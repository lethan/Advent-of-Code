defmodule AoC.Year2024.Day23 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(%{}, fn [a, b], acc ->
      acc
      |> Map.update(a, MapSet.new([b]), fn val -> MapSet.put(val, b) end)
      |> Map.update(b, MapSet.new([a]), fn val -> MapSet.put(val, a) end)
    end)
  end

  defp three_interconnected(connection, connections) do
    Map.get(connections, connection)
    |> MapSet.to_list()
    |> common_connection(connections)
    |> Enum.reduce(MapSet.new(), fn {a, b}, acc ->
      MapSet.put(acc, MapSet.new([a, b, connection]))
    end)
  end

  defp common_connection(list, connections, result \\ [])
  defp common_connection([], _, result), do: result

  defp common_connection([a | rest], connections, result) do
    result =
      rest
      |> Enum.reduce(result, fn b, acc ->
        if Map.get(connections, a) |> MapSet.member?(b) do
          [{a, b} | acc]
        else
          acc
        end
      end)

    common_connection(rest, connections, result)
  end

  defp subnets(connections) do
    connections
    |> Enum.reduce(MapSet.new(), fn {computer, connections}, acc ->
      acc
      |> Enum.reduce(MapSet.put(acc, MapSet.new([computer])), fn subnet, acc ->
        if MapSet.subset?(subnet, connections) do
          MapSet.put(acc, MapSet.put(subnet, computer))
        else
          acc
        end
      end)
    end)
  end

  def task1(input) do
    input
    |> Enum.filter(fn {key, _} -> String.starts_with?(key, "t") end)
    |> Enum.reduce(MapSet.new(), fn {connection, _}, acc ->
      three_interconnected(connection, input)
      |> MapSet.union(acc)
    end)
    |> Enum.count()
  end

  def task2(input) do
    input
    |> subnets()
    |> Enum.sort_by(fn v -> Enum.count(v) end, :desc)
    |> Enum.at(0)
    |> Enum.sort()
    |> Enum.join(",")
  end
end

# input = AoC.Year2024.Day23.import("input/2024/input_day23.txt")

# input
# |> AoC.Year2024.Day23.task1()
# |> IO.puts()

# input
# |> AoC.Year2024.Day23.task2()
# |> IO.puts()
