defmodule Day3 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&split_to_map/1)
    |> Enum.map(fn x -> {x, []} end)
  end

  defp split_to_map(string) do
    string
    |> String.graphemes
    |> Enum.map(fn x ->
      case x do
        "." ->
          :empty
        "#" ->
          :tree
      end
    end)
  end

  def task1(input, counter \\ 0, right \\ 3, down \\ 1)
  def task1([], counter, _right, _down), do: counter
  def task1(input, counter, right, down) do
    next = input
    |> steps(right, down)
    task1(next, counter + if current_location(next) == :tree do 1 else 0 end, right, down)
  end

  def task2(input) do
    [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
    |> Enum.map(fn {right, down} -> task1(input, 0, right, down) end)
    |> Enum.reduce(&(&1 * &2))
  end

  def current_location(map) do
    case map do
      [{[current | _line], _visited} | _rest] ->
        current
      _ ->
        nil
    end
  end

  def steps(map, right, down) do
    map
    |> step_right(right)
    |> step_down(down)
  end

  def step_right(map, steps \\ 1)
  def step_right(map, 0), do: map
  def step_right(map, steps) do
    step_right(Enum.map(map, &line_right/1), steps - 1)
  end

  defp line_right({[current], visited}) do
    {Enum.reverse([current | visited]), []}
  end
  defp line_right({[current | rest], visited}) do
    {rest, [current | visited]}
  end

  def step_down(map, counter \\ 1)
  def step_down([], _counter), do: []
  def step_down(map, 0), do: map
  def step_down([_ | tail], counter), do: step_down(tail, counter - 1)
end

input = Day3.import("input_day03.txt")

input
|> Day3.task1
|> IO.puts

input
|> Day3.task2
|> IO.puts
