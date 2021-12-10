defmodule AOC2015.Day6 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&convert_to_data/1)
  end

  defp convert_to_data(string) do
    [instruction, on_off, x1, y1, x2, y2] =
      Regex.run(
        ~r/(toggle|turn (on|off)) ([0-9]+),([0-9]+) through ([0-9]+),([0-9]+)/,
        string,
        capture: :all_but_first
      )

    instruction =
      case instruction do
        "toggle" ->
          :toggle

        _ ->
          if on_off == "on" do
            :on
          else
            :off
          end
      end

    [x1, y1, x2, y2] =
      [x1, y1, x2, y2]
      |> Enum.map(&String.to_integer/1)

    {instruction, {x1, y1}, {x2, y2}}
  end

  defp on_off_map(instructions, map \\ %{})
  defp on_off_map([], map), do: map

  defp on_off_map([{:on, {x1, y1}, {x2, y2}} | rest], map) do
    coords =
      for x <- x1..x2,
          y <- y1..y2,
          do: {x, y}

    new_map =
      Enum.reduce(coords, map, fn coord, acc ->
        Map.put(acc, coord, true)
      end)

    on_off_map(rest, new_map)
  end

  defp on_off_map([{:off, {x1, y1}, {x2, y2}} | rest], map) do
    coords =
      for x <- x1..x2,
          y <- y1..y2,
          do: {x, y}

    new_map =
      Enum.reduce(coords, map, fn coord, acc ->
        Map.put(acc, coord, false)
      end)

    on_off_map(rest, new_map)
  end

  defp on_off_map([{:toggle, {x1, y1}, {x2, y2}} | rest], map) do
    coords =
      for x <- x1..x2,
          y <- y1..y2,
          do: {x, y}

    new_map =
      Enum.reduce(coords, map, fn coord, acc ->
        Map.update(acc, coord, true, &Kernel.not/1)
      end)

    on_off_map(rest, new_map)
  end

  defp brightness_map(instructions, map \\ %{})
  defp brightness_map([], map), do: map

  defp brightness_map([{:on, {x1, y1}, {x2, y2}} | rest], map) do
    coords =
      for x <- x1..x2,
          y <- y1..y2,
          do: {x, y}

    new_map =
      Enum.reduce(coords, map, fn coord, acc ->
        Map.update(acc, coord, 1, &(&1 + 1))
      end)

    brightness_map(rest, new_map)
  end

  defp brightness_map([{:off, {x1, y1}, {x2, y2}} | rest], map) do
    coords =
      for x <- x1..x2,
          y <- y1..y2,
          do: {x, y}

    new_map =
      Enum.reduce(coords, map, fn coord, acc ->
        Map.update(acc, coord, 0, fn val ->
          case val do
            0 ->
              0

            val ->
              val - 1
          end
        end)
      end)

    brightness_map(rest, new_map)
  end

  defp brightness_map([{:toggle, {x1, y1}, {x2, y2}} | rest], map) do
    coords =
      for x <- x1..x2,
          y <- y1..y2,
          do: {x, y}

    new_map =
      Enum.reduce(coords, map, fn coord, acc ->
        Map.update(acc, coord, 2, &(&1 + 2))
      end)

    brightness_map(rest, new_map)
  end

  def task1(input) do
    input
    |> on_off_map()
    |> Enum.filter(&elem(&1, 1))
    |> Enum.count()
  end

  def task2(input) do
    input
    |> brightness_map()
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.sum()
  end
end

input = AOC2015.Day6.import("input_day06.txt")

input
|> AOC2015.Day6.task1()
|> IO.puts()

input
|> AOC2015.Day6.task2()
|> IO.puts()
