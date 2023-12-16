defmodule AoC.Year2022.Day6 do
  alias AoC.Zipper

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
  end

  defp find_unique_chars(
         <<char::binary-1, rest::binary>>,
         number_of_chars \\ 4,
         counter \\ 1,
         zipper \\ Zipper.new()
       ) do
    zipper = Zipper.enqueue(zipper, char)

    case Zipper.size(zipper) do
      ^number_of_chars ->
        zipper
        |> Enum.uniq()
        |> Enum.count()
        |> case do
          ^number_of_chars ->
            counter

          _ ->
            {_, zipper} = Zipper.dequeue(zipper)
            find_unique_chars(rest, number_of_chars, counter + 1, zipper)
        end

      _ ->
        find_unique_chars(rest, number_of_chars, counter + 1, zipper)
    end
  end

  def task1(input) do
    input
    |> find_unique_chars
  end

  def task2(input) do
    input
    |> find_unique_chars(14)
  end
end

# input = AoC.Year2022.Day6.import("input/2022/input_day06.txt")

# input
# |> AoC.Year2022.Day6.task1()
# |> IO.puts()

# input
# |> AoC.Year2022.Day6.task2()
# |> IO.puts()
