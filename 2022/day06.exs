defmodule AOC2022.Day6 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
  end

  def find_unique_chars(
        <<char::binary-1, rest::binary>>,
        number_of_chars \\ 4,
        counter \\ 1,
        {adding, removing} \\ {[], []}
      ) do
    adding = [char | adding]

    case Enum.count(adding) + Enum.count(removing) do
      ^number_of_chars ->
        (adding ++ removing)
        |> Enum.uniq()
        |> Enum.count()
        |> case do
          ^number_of_chars ->
            counter

          _ ->
            case removing do
              [_ | remove_rest] ->
                find_unique_chars(rest, number_of_chars, counter + 1, {adding, remove_rest})

              [] ->
                [_ | remove_rest] = Enum.reverse(adding)
                find_unique_chars(rest, number_of_chars, counter + 1, {[], remove_rest})
            end
        end

      _ ->
        find_unique_chars(rest, number_of_chars, counter + 1, {adding, removing})
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

input = AOC2022.Day6.import("input_day06.txt")

input
|> AOC2022.Day6.task1()
|> IO.puts()

input
|> AOC2022.Day6.task2()
|> IO.puts()
