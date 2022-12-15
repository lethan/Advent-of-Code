defmodule AOC2022.Day15 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn string ->
      [sensor_x, sensor_y, beacon_x, beacon_y] =
        Regex.run(
          ~r/^Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)$/,
          string,
          capture: :all_but_first
        )
        |> Enum.map(&String.to_integer/1)

      radius = abs(sensor_x - beacon_x) + abs(sensor_y - beacon_y)
      {{sensor_x, sensor_y}, {beacon_x, beacon_y}, radius}
    end)
  end

  def coverage_line(sensor_beacon_list, line_number) do
    {ranges, beacons} =
      sensor_beacon_list
      |> Enum.reduce({[], []}, fn {{sensor_x, sensor_y}, {beacon_x, beacon_y}, radius},
                                  {acc, beacons} ->
        beacons =
          if beacon_y == line_number do
            [{beacon_x, beacon_x} | beacons]
          else
            beacons
          end

        span = radius - abs(sensor_y - line_number)

        acc = add_range(acc, List.wrap(create_range(span, sensor_x)))
        {acc, beacons}
      end)

    beacons
    |> Enum.reduce(ranges, fn range, acc ->
      remove_range(acc, range)
    end)
  end

  def find_beacon(sensor_beacon_list, {min, max} = range) do
    min..max
    |> Enum.reduce_while(nil, fn y, acc ->
      case beacons_line_in_range(sensor_beacon_list, y, [range]) do
        [{x, x}] ->
          {:halt, {x, y}}

        _ ->
          {:cont, acc}
      end
    end)
  end

  def beacons_line_in_range(sensor_beacon_list, line_number, ranges) do
    sensor_beacon_list
    |> Enum.reduce_while(ranges, fn {{sensor_x, sensor_y}, _beacon, radius}, acc ->
      case acc do
        [] ->
          {:halt, []}

        _ ->
          span = radius - abs(sensor_y - line_number)

          {:cont, remove_range(acc, create_range(span, sensor_x))}
      end
    end)
  end

  def create_range(span, _x) when span < 0, do: nil
  def create_range(span, x), do: {x - span, x + span}

  def add_range(ranges, add_ranges, acc \\ [])

  def add_range([{low1, high1}, {low2, high2} | rest], add_ranges, acc) when low2 <= high1 do
    add_range([{min(low1, low2), max(high1, high2)} | rest], add_ranges, acc)
  end

  def add_range(ranges, [{low1, high1}, {low2, high2} | rest], acc) when low2 <= high1 do
    add_range(ranges, [{min(low1, low2), max(high1, high2)} | rest], acc)
  end

  def add_range(ranges, [], []), do: ranges
  def add_range([], add_ranges, []), do: add_ranges
  def add_range([], [], acc), do: Enum.reverse(acc)

  def add_range([val | rest], [], acc), do: add_range(rest, [], [val | acc])
  def add_range([], [val | rest], acc), do: add_range([], rest, [val | acc])

  def add_range(
        [{low, high} | ranges_rest] = ranges,
        [{add_low, add_high} | add_rest] = add_ranges,
        acc
      ) do
    cond do
      low <= add_low and high >= add_high ->
        add_range(ranges, add_rest, acc)

      add_low <= low and add_high >= high ->
        add_range(ranges_rest, add_ranges, acc)

      high >= add_low and low <= add_high ->
        add_range([{min(low, add_low), max(high, add_high)} | ranges_rest], add_rest, acc)

      high < add_low ->
        add_range(ranges_rest, add_ranges, [{low, high} | acc])

      add_high < low ->
        add_range(ranges, add_rest, [{add_low, add_high} | acc])
    end
  end

  def remove_range(ranges, nil), do: ranges
  def remove_range([], _), do: []

  def remove_range(ranges, {low, high}) do
    Enum.map(ranges, fn {range_low, range_high} = range ->
      cond do
        low <= range_low and high >= range_high ->
          []

        high < range_low or low > range_high ->
          [range]

        high >= range_high ->
          [{range_low, low - 1}]

        low <= range_low ->
          [{high + 1, range_high}]

        true ->
          [{range_low, low - 1}, {high + 1, range_high}]
      end
    end)
    |> Enum.concat()
  end

  def range_size(ranges) do
    ranges
    |> Enum.reduce(0, fn {low, high}, acc ->
      acc + high - low + 1
    end)
  end

  def task1(input) do
    input
    |> coverage_line(2_000_000)
    |> range_size()
  end

  def task2(input) do
    {x, y} =
      input
      |> find_beacon({0, 4_000_000})

    x * 4_000_000 + y
  end
end

input = AOC2022.Day15.import("input_day15.txt")

input
|> AOC2022.Day15.task1()
|> IO.puts()

input
|> AOC2022.Day15.task2()
|> IO.puts()
