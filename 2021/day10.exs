defmodule Day10 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp validate(chars, find_char \\ "", added_chars \\ [])
  defp validate([], "", added_chars), do: {:ok, [], Enum.reverse(added_chars)}

  defp validate([], find_char, added_chars) do
    validate([find_char], find_char, [find_char | added_chars])
  end

  defp validate([find_char | rest], find_char, added_chars) do
    {:ok, rest, added_chars}
  end

  defp validate([char | _rest], _find_char, added_chars) when char in [")", "]", "}", ">"] do
    {:syntax_error, char, added_chars}
  end

  defp validate([char | rest], find_char, added_chars) when char in ["(", "[", "{", "<"] do
    end_char =
      case char do
        "(" -> ")"
        "[" -> "]"
        "{" -> "}"
        "<" -> ">"
      end

    case validate(rest, end_char, added_chars) do
      {:ok, rest, added} ->
        validate(rest, find_char, added)

      {:syntax_error, char, added} ->
        {:syntax_error, char, added}
    end
  end

  defp added_value(added_chars) do
    added_chars
    |> Enum.reduce(0, fn char, acc ->
      5 * acc +
        case char do
          ")" -> 1
          "]" -> 2
          "}" -> 3
          ">" -> 4
        end
    end)
  end

  def task1(input) do
    input
    |> Enum.map(&validate/1)
    |> Enum.reduce(0, fn {status, value, _}, acc ->
      case status do
        :syntax_error ->
          acc +
            case value do
              ")" -> 3
              "]" -> 57
              "}" -> 1197
              ">" -> 25137
            end

        _ ->
          acc
      end
    end)
  end

  def task2(input) do
    values =
      input
      |> Enum.map(&validate/1)
      |> Enum.filter(&(elem(&1, 0) != :syntax_error))
      |> Enum.map(fn {_, _, added} -> added_value(added) end)
      |> Enum.sort()

    Enum.at(values, div(Enum.count(values), 2))
  end
end

input = Day10.import("input_day10.txt")

input
|> Day10.task1()
|> IO.puts()

input
|> Day10.task2()
|> IO.puts()
