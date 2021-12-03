defmodule Day3 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
  end

  def task1(list) do
    list
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip_reduce([], fn elements, acc ->
      [Enum.frequencies(elements) | acc]
    end)
    |> Enum.reverse()
    |> Enum.map(fn e ->
      Enum.sort_by(e, &elem(&1, 1), &<=/2)
      |> Enum.map(&elem(&1, 0))
    end)
    |> Enum.zip()
    |> Enum.map(fn e ->
      Tuple.to_list(e)
      |> Enum.join()
      |> String.to_integer(2)
    end)
    |> Enum.reduce(1, &*/2)
  end

  def task2(list) do
    graphemes =
      list
      |> Enum.map(&String.graphemes/1)

    [
      graphemes
      |> find_oxygen()
      |> Enum.join()
      |> String.to_integer(2),
      graphemes
      |> find_scrubber()
      |> Enum.join()
      |> String.to_integer(2)
    ]
    |> Enum.reduce(1, &*/2)
  end

  defp numbers_at(list, index) do
    list
    |> Enum.zip_reduce([], fn elements, acc ->
      [Enum.frequencies(elements) | acc]
    end)
    |> Enum.reverse()
    |> Enum.at(index)
  end

  defp find_oxygen(list, index \\ 0)
  defp find_oxygen([value], _index), do: value

  defp find_oxygen(list, index) do
    %{"0" => zeroes, "1" => ones} = numbers_at(list, index)

    cond do
      zeroes > ones ->
        Enum.filter(list, fn x ->
          Enum.at(x, index) == "0"
        end)

      ones > zeroes ->
        Enum.filter(list, fn x ->
          Enum.at(x, index) == "1"
        end)

      true ->
        Enum.filter(list, fn x ->
          Enum.at(x, index) == "1"
        end)
    end
    |> find_oxygen(index + 1)
  end

  defp find_scrubber(list, index \\ 0)
  defp find_scrubber([value], _index), do: value

  defp find_scrubber(list, index) do
    %{"0" => zeroes, "1" => ones} = numbers_at(list, index)

    cond do
      zeroes > ones ->
        Enum.filter(list, fn x ->
          Enum.at(x, index) == "1"
        end)

      ones > zeroes ->
        Enum.filter(list, fn x ->
          Enum.at(x, index) == "0"
        end)

      true ->
        Enum.filter(list, fn x ->
          Enum.at(x, index) == "0"
        end)
    end
    |> find_scrubber(index + 1)
  end
end

input = Day3.import("input_day03.txt")

input
|> Day3.task1()
|> IO.puts()

input
|> Day3.task2()
|> IO.puts()
