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
  defp turn(orientation, degrees) do
    if degrees < 0 do
      turn(orientation, 360 + degrees)
    else
      case orientation do
        :north ->
          turn(:east, degrees - 90)
        :east ->
          turn(:south, degrees - 90)
        :south ->
          turn(:west, degrees - 90)
        :west ->
          turn(:north, degrees - 90)
      end
    end
  end

  defp move({command, number}, {east_west, north_south, orientation}) do
    case command do
      :north ->
        {east_west, north_south + number, orientation}
      :south ->
        {east_west, north_south - number, orientation}
      :east ->
        {east_west + number, north_south, orientation}
      :west ->
        {east_west - number, north_south, orientation}
      :right ->
        {east_west, north_south, turn(orientation, number)}
      :left ->
        {east_west, north_south, turn(orientation, -number)}
      :forward ->
        case orientation do
          :north ->
            {east_west, north_south + number, orientation}
          :south ->
            {east_west, north_south - number, orientation}
          :east ->
            {east_west + number, north_south, orientation}
          :west ->
            {east_west - number, north_south, orientation}
        end
    end
  end

  defp turn_waypoint(orientation, 0), do: orientation
  defp turn_waypoint(orientation = {east_west, north_south}, degrees) do
    if degrees < 0 do
      turn_waypoint(orientation, 360 + degrees)
    else
      turn_waypoint({north_south, -east_west}, degrees - 90)
    end
  end

  def move_waypoint({command, number}, {east_west, north_south, waypoint_east_west, waypoint_north_south}) do
    case command do
      :north ->
        {east_west, north_south, waypoint_east_west, waypoint_north_south + number}
      :south ->
        {east_west, north_south, waypoint_east_west, waypoint_north_south - number}
      :east ->
        {east_west, north_south, waypoint_east_west + number, waypoint_north_south}
      :west ->
        {east_west, north_south, waypoint_east_west - number, waypoint_north_south}
      :right ->
        {new_way_east_west, new_way_north_south} = turn_waypoint({waypoint_east_west, waypoint_north_south}, number)
        {east_west, north_south, new_way_east_west, new_way_north_south}
      :left ->
        {new_way_east_west, new_way_north_south} = turn_waypoint({waypoint_east_west, waypoint_north_south}, -number)
        {east_west, north_south, new_way_east_west, new_way_north_south}
      :forward ->
        {east_west + number * waypoint_east_west, north_south + number * waypoint_north_south, waypoint_east_west, waypoint_north_south}
    end
  end

  def task1(input) do
    {east_west, north_south, _direction} = input
    |> Enum.reduce({0, 0, :east}, fn command, acc ->
      move(command, acc)
    end)

    abs(east_west) + abs(north_south)
  end

  def task2(input) do
    {east_west, north_south, _waypoint_east_west, _waypoint_north_south} = input
    |> Enum.reduce({0, 0, 10, 1}, fn command, acc ->
      move_waypoint(command, acc)
    end)

    abs(east_west) + abs(north_south)
  end
end

input = Day12.import("input_day12.txt")

input
|> Day12.task1
|> IO.puts

input
|> Day12.task2
|> IO.puts
