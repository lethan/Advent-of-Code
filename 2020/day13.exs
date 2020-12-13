defmodule Day13 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_data
  end

  defp convert_to_data([start_time, bus_list]) do
    {String.to_integer(start_time), Enum.map(String.split(bus_list, ","), &(if &1 == "x" do &1 else String.to_integer(&1) end))}
  end

  defp find_first_bus(time, bus_list) do
    case Enum.find(bus_list, &(rem(time, &1) == 0)) do
      nil ->
        find_first_bus(time+1, bus_list)
      bus ->
        {time, bus}
    end
  end

  defp find_multiplier([], value, _), do: value
  defp find_multiplier(list = [{bus, shift} | rest], value, multi) do
    if rem(value + shift, bus) == 0 do
      find_multiplier(rest, value, bus*multi)
    else
      find_multiplier(list, value + multi, multi)
    end
  end

  def task1(input) do
    {start_time, bus_list} = input
    {time, bus} = find_first_bus(start_time, Enum.reject(bus_list, &(&1 == "x")))
    (time - start_time) * bus
  end

  def task2({_, bus_list}) do
    bus_list
    |> Enum.with_index
    |> Enum.reject(fn {bus, _} -> bus == "x" end)
    |> find_multiplier(1,1)
  end
end

input = Day13.import("input_day13.txt")

input
|> Day13.task1
|> IO.puts

input
|> Day13.task2
|> IO.puts
