defmodule AoC.Year2022.Day2 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.split(" ")
      |> Enum.map(&String.to_atom/1)
      |> List.to_tuple()
    end)
  end

  def play(plays, strategy \\ &basic_strategy/2, score \\ 0)
  def play([], _, score), do: score

  def play([{oppenent_play, play} | rest], strategy, score) do
    my_play = strategy.(play, oppenent_play)

    score =
      score + winner_points(oppenent_play, my_play) +
        case my_play do
          :A -> 1
          :B -> 2
          :C -> 3
        end

    play(rest, strategy, score)
  end

  defp winner_points(play, play), do: 3
  defp winner_points(:A, :B), do: 6
  defp winner_points(:B, :C), do: 6
  defp winner_points(:C, :A), do: 6
  defp winner_points(_, _), do: 0

  defp basic_strategy(:X, _oppenent_play), do: :A
  defp basic_strategy(:Y, _oppenent_play), do: :B
  defp basic_strategy(:Z, _oppenent_play), do: :C

  defp real_strategy(:X, :A), do: :C
  defp real_strategy(:X, :B), do: :A
  defp real_strategy(:X, :C), do: :B
  defp real_strategy(:Y, oppenent_play), do: oppenent_play
  defp real_strategy(:Z, :A), do: :B
  defp real_strategy(:Z, :B), do: :C
  defp real_strategy(:Z, :C), do: :A

  def task1(input) do
    input
    |> play
  end

  def task2(input) do
    input
    |> play(&real_strategy/2)
  end
end

# input = AoC.Year2022.Day2.import("input/2022/input_day02.txt")

# input
# |> AoC.Year2022.Day2.task1()
# |> IO.puts()

# input
# |> AoC.Year2022.Day2.task2()
# |> IO.puts()
