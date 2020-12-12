defmodule Day12 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn string ->
      [command, value] = Regex.run(~r/([NSEWLRF])([0-9]+)/, string, capture: :all_but_first)
      number = String.to_integer(value)
      case command do
        "N" ->
          {:north, number}
        "S" ->
          {:south, number}
        "E" ->
          {:east, number}
        "W" ->
          {:west, number}
        "R" ->
          {:right, number}
        "L" ->
          {:left, number}
        "F" ->
          {:forward, number}
      end
    end)
  end

  defp turn(orientation, 0), do: orientation
  defp turn(orientation = {east, north}, degrees) do
    if degrees < 0 do
      turn(orientation, 360 + degrees)
    else
      turn({north, -east}, degrees - 90)
    end
  end

  defp move({command, number}, {east, north, orientation_east, orientation_north}) do
    case command do
      :north ->
        {east, north + number, orientation_east, orientation_north}
      :south ->
        {east, north - number, orientation_east, orientation_north}
      :east ->
        {east + number, north, orientation_east, orientation_north}
      :west ->
        {east - number, north, orientation_east, orientation_north}
      :right ->
        {new_orientation_east, new_orientation_north} = turn({orientation_east, orientation_north}, number)
        {east, north, new_orientation_east, new_orientation_north}
      :left ->
        {new_orientation_east, new_orientation_north} = turn({orientation_east, orientation_north}, -number)
        {east, north, new_orientation_east, new_orientation_north}
      :forward ->
        {east + number * orientation_east, north + number * orientation_north, orientation_east, orientation_north}
    end
  end

  defp move_waypoint({command, number}, {east, north, waypoint_east, waypoint_north}) do
    case command do
      :north ->
        {east, north, waypoint_east, waypoint_north + number}
      :south ->
        {east, north, waypoint_east, waypoint_north - number}
      :east ->
        {east, north, waypoint_east + number, waypoint_north}
      :west ->
        {east, north, waypoint_east - number, waypoint_north}
      :right ->
        {new_way_east, new_way_north} = turn({waypoint_east, waypoint_north}, number)
        {east, north, new_way_east, new_way_north}
      :left ->
        {new_way_east, new_way_north} = turn({waypoint_east, waypoint_north}, -number)
        {east, north, new_way_east, new_way_north}
      :forward ->
        {east + number * waypoint_east, north + number * waypoint_north, waypoint_east, waypoint_north}
    end
  end

  def task1(input) do
    {east, north, _orientation_east, _orientation_north} = input
    |> Enum.reduce({0, 0, 1, 0}, fn command, acc ->
      move(command, acc)
    end)

    abs(east) + abs(north)
  end

  def task2(input) do
    {east, north, _waypoint_east, _waypoint_north} = input
    |> Enum.reduce({0, 0, 10, 1}, fn command, acc ->
      move_waypoint(command, acc)
    end)

    abs(east) + abs(north)
  end
end

input = Day12.import("input_day12.txt")

input
|> Day12.task1
|> IO.puts

input
|> Day12.task2
|> IO.puts
