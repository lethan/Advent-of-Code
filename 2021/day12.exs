defmodule Day12 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_data()
  end

  defp convert_to_data(input) do
    input
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(%{}, fn [a, b], acc ->
      acc
      |> update_graph(a, b)
      |> update_graph(b, a)
    end)
  end

  defp cave_type(string) do
    case(string == String.upcase(string)) do
      true ->
        :large

      false ->
        :small
    end
  end

  defp update_graph(graph, a, b) do
    pair = {String.to_atom(b), cave_type(b)}

    graph
    |> Map.update(String.to_atom(a), [pair], fn list ->
      [pair | list]
    end)
  end

  defp paths(current_cave, end_cave, map, current_path, valid_paths, visit_limited \\ true) do
    current_path = [current_cave | current_path]

    cond do
      current_cave == end_cave ->
        valid_paths + 1

      true ->
        map
        |> Map.fetch!(current_cave)
        |> Enum.reduce(valid_paths, fn cave_info, acc ->
          case cave_info do
            {cave, :small} when cave in [:start, :end] ->
              if not Enum.member?(current_path, cave) do
                paths(cave, end_cave, map, current_path, acc, visit_limited)
              else
                acc
              end

            {cave, :small} ->
              if not Enum.member?(current_path, cave) do
                paths(cave, end_cave, map, current_path, acc, visit_limited)
              else
                case visit_limited do
                  false ->
                    paths(cave, end_cave, map, current_path, acc, true)

                  true ->
                    acc
                end
              end

            {cave, :large} ->
              paths(cave, end_cave, map, current_path, acc, visit_limited)
          end
        end)
    end
  end

  def task1(input) do
    paths(:start, :end, input, [], 0)
  end

  def task2(input) do
    paths(:start, :end, input, [], 0, false)
  end
end

input = Day12.import("input_day12.txt")

input
|> Day12.task1()
|> IO.puts()

input
|> Day12.task2()
|> IO.puts()
