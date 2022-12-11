defmodule AOC2022.Day10 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      case String.split(str, " ") do
        ["noop"] ->
          {:noop}

        ["addx", value] ->
          {:addx, String.to_integer(value)}
      end
    end)
  end

  def run(instructions, instruction \\ 1, results \\ [{0, 1}])
  def run([], _instruction, results), do: results

  def run([{:noop} | rest], instruction, results) do
    run(rest, instruction + 1, results)
  end

  def run([{:addx, value} | rest], instruction, [{_, x} | _] = results) do
    run(rest, instruction + 2, [{instruction + 2, x + value} | results])
  end

  def signal_strength(sampling, times) do
    times =
      times
      |> Enum.map(fn x -> {x, 0} end)

    sampling
    |> Enum.reverse()
    |> Enum.reduce(times, fn {cycle, value}, acc ->
      Enum.map(acc, fn {max_cycle, current} ->
        if max_cycle >= cycle do
          {max_cycle, value}
        else
          {max_cycle, current}
        end
      end)
    end)
    |> Enum.reduce(0, fn {cycle, value}, acc -> acc + cycle * value end)
  end

  def draw_crt(sampling) do
    sampling = Enum.reverse(sampling)

    1..240
    |> Enum.reduce({"", sampling}, fn cycle, {acc, sampling} ->
      {dropped, sampling} =
        Enum.split_while(sampling, fn {sample_cycle, _} -> sample_cycle <= cycle end)

      {sample_cycle, x} = List.last(dropped)
      sampling = [{sample_cycle, x} | sampling]

      acc =
        acc <>
          case rem(cycle - 1, 40) do
            val when val in (x - 1)..(x + 1) ->
              "#"

            _ ->
              " "
          end <>
          case rem(cycle, 40) do
            0 ->
              "\n"

            _ ->
              ""
          end

      {acc, sampling}
    end)
    |> elem(0)
  end

  def task1(input) do
    input
    |> run()
    |> signal_strength([20, 60, 100, 140, 180, 220])
  end

  def task2(input) do
    input
    |> run()
    |> draw_crt()
  end
end

input = AOC2022.Day10.import("input_day10.txt")

input
|> AOC2022.Day10.task1()
|> IO.puts()

input
|> AOC2022.Day10.task2()
|> IO.puts()
