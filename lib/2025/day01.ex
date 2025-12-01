defmodule AoC.Year2025.Day1 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      {direction, distance} = String.split_at(str, 1)

      direction =
        case direction do
          "L" -> :left
          "R" -> :right
        end

      {direction, String.to_integer(distance)}
    end)
  end

  defp turn_dial_simple(list), do: turn_dial_simple(50, list, 0)

  defp turn_dial_simple(_, [], visited), do: visited

  defp turn_dial_simple(position, [{direction, distance} | rest], visited) do
    new_position =
      case direction do
        :left -> position - distance
        :right -> position + distance
      end
      |> rem(100)

    new_visited = if(new_position == 0, do: visited + 1, else: visited)
    turn_dial_simple(new_position, rest, new_visited)
  end

  defp turn_dial(list), do: turn_dial(50, list, 0)

  defp turn_dial(_, [], visited), do: visited

  defp turn_dial(position, [{direction, distance} | rest], visited) do
    visited = visited + div(distance, 100)
    distance = rem(distance, 100)

    new_position =
      case direction do
        :left -> position - distance
        :right -> position + distance
      end

    {position, visited} =
      case new_position do
        0 -> {0, visited + 1}
        neg when neg < 0 and position != 0 -> {neg + 100, visited + 1}
        neg when neg < 0 -> {neg + 100, visited}
        over when over > 99 -> {over - 100, visited + 1}
        x -> {x, visited}
      end

    turn_dial(position, rest, visited)
  end

  def task1(input) do
    input
    |> turn_dial_simple()
  end

  def task2(input) do
    input
    |> turn_dial()
  end
end

# input = AoC.Year2025.Day1.import("input/2025/input_day01.txt")

# input
# |> AoC.Year2025.Day1.task1()
# |> IO.puts()

# input
# |> AoC.Year2025.Day1.task2()
# |> IO.puts()
