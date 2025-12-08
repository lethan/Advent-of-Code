defmodule AoC.Year2025.Day8 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp distances(junctions, distances \\ %{})
  defp distances([_], distances), do: distances

  defp distances([point1 = {x1, y1, z1} | rest], distances) do
    distances =
      rest
      |> Enum.reduce(distances, fn point2 = {x2, y2, z2}, acc ->
        Map.put(acc, {point1, point2}, Integer.pow(x1 - x2, 2) + Integer.pow(y1 - y2, 2) + Integer.pow(z1 - z2, 2))
      end)

    distances(rest, distances)
  end

  defp join(junctions, max_joins \\ 1000) do
    {pointers, sets} =
      junctions
      |> Enum.with_index()
      |> Enum.reduce({%{}, %{}}, fn {junction, index}, {pointers, sets} ->
        {Map.put(pointers, junction, index), Map.put(sets, index, MapSet.new([junction]))}
      end)

    {_pointers, sets, _counter, last_junction} =
      junctions
      |> distances()
      |> Enum.sort_by(fn {_, v} -> v end)
      |> Enum.reduce_while({pointers, sets, 0, nil}, fn {{junction1, junction2} = junction, _},
                                                        {pointers, sets, counter, _last_junction} = acc ->
        cond do
          counter == max_joins ->
            {:halt, acc}

          map_size(sets) == 1 ->
            {:halt, acc}

          true ->
            pointer1 = Map.get(pointers, junction1)
            pointer2 = Map.get(pointers, junction2)

            if pointer1 == pointer2 do
              {:cont, {pointers, sets, counter + 1, junction}}
            else
              set1 = Map.get(sets, pointer1)
              set2 = Map.get(sets, pointer2)
              set = MapSet.union(set1, set2)

              sets =
                sets
                |> Map.delete(pointer2)
                |> Map.put(pointer1, set)

              pointers =
                set
                |> Enum.reduce(pointers, fn pointer, acc ->
                  Map.put(acc, pointer, pointer1)
                end)

              {:cont, {pointers, sets, counter + 1, junction}}
            end
        end
      end)

    {sets, last_junction}
  end

  def task1(input) do
    input
    |> join()
    |> elem(0)
    |> Enum.map(fn {_, set} -> MapSet.size(set) end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(1, fn count, acc -> count * acc end)
  end

  def task2(input) do
    input
    |> join(:infinity)
    |> elem(1)
    |> Tuple.to_list()
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(1, fn v, acc -> v * acc end)
  end
end

# input = AoC.Year2025.Day8.import("input/2025/input_day08.txt")

# input
# |> AoC.Year2025.Day8.task1()
# |> IO.puts()

# input
# |> AoC.Year2025.Day8.task2()
# |> IO.puts()
