defmodule AoC.Year2022.Day9 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      [direction, steps] =
        str
        |> String.split(" ")

      direction =
        case direction do
          "U" -> :up
          "D" -> :down
          "L" -> :left
          "R" -> :right
        end

      steps = String.to_integer(steps)

      {direction, steps}
    end)
  end

  defp move(instructions, head \\ {0, 0}, tails \\ [{0, 0}], visited \\ %{{0, 0} => true})
  defp move([], _head, _tails, visisted), do: visisted

  defp move([{direction, steps} | rest], head, tails, visited) do
    {head, tails, visited} =
      1..steps
      |> Enum.reduce({head, tails, visited}, fn _, {{head_x, head_y}, tails, acc} ->
        head =
          case direction do
            :up ->
              {head_x, head_y + 1}

            :down ->
              {head_x, head_y - 1}

            :left ->
              {head_x - 1, head_y}

            :right ->
              {head_x + 1, head_y}
          end

        {tail, tails} =
          tails
          |> Enum.reduce({head, []}, fn {tail_x, tail_y}, {{head_x, head_y}, acc2} ->
            diff_x = head_x - tail_x
            diff_y = head_y - tail_y

            tail =
              case {abs(diff_x), abs(diff_y)} do
                {2, 0} ->
                  {tail_x + div(diff_x, abs(diff_x)), tail_y}

                {0, 2} ->
                  {tail_x, tail_y + div(diff_y, abs(diff_y))}

                {a, b} when a == 2 or b == 2 ->
                  {tail_x + div(diff_x, abs(diff_x)), tail_y + div(diff_y, abs(diff_y))}

                _ ->
                  {tail_x, tail_y}
              end

            {tail, [tail | acc2]}
          end)

        visited = Map.put(acc, tail, true)
        {head, Enum.reverse(tails), visited}
      end)

    move(rest, head, tails, visited)
  end

  def task1(input) do
    input
    |> move()
    |> Enum.count()
  end

  def task2(input) do
    input
    |> move({0, 0}, List.duplicate({0, 0}, 9))
    |> Enum.count()
  end
end

# input = AoC.Year2022.Day9.import("input/2022/input_day09.txt")

# input
# |> AoC.Year2022.Day9.task1()
# |> IO.puts()

# input
# |> AoC.Year2022.Day9.task2()
# |> IO.puts()
