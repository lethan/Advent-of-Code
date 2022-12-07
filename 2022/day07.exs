defmodule AOC2022.Day7 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_directory
  end

  defp convert_to_directory(commands) do
    status = :await_command
    dir = []

    {_, _, structure} =
      commands
      |> Enum.reduce({dir, status, %{"/" => %{}}}, fn str,
                                                      {current_dir, current_status, structure} ->
        case current_status do
          :await_command ->
            ["$", command | rest] =
              str
              |> String.split(" ")

            command(command, rest, current_dir, current_status, structure)

          :possible_data ->
            case String.split(str, " ") do
              ["$", command | rest] ->
                command(command, rest, current_dir, current_status, structure)

              ["dir", dir] ->
                structure = put_in(structure, Enum.reverse([dir | current_dir]), %{})
                {current_dir, current_status, structure}

              [size, file] ->
                structure =
                  put_in(structure, Enum.reverse([file | current_dir]), String.to_integer(size))

                {current_dir, current_status, structure}
            end
        end
      end)

    structure
  end

  defp command("ls", [], current_dir, _current_status, structure) do
    {current_dir, :possible_data, structure}
  end

  defp command("cd", [".."], current_dir, _current_status, structure) do
    [_ | current_dir] = current_dir
    {current_dir, :await_command, structure}
  end

  defp command("cd", [path], current_dir, _current_status, structure) do
    current_dir = [path | current_dir]
    {current_dir, :await_command, structure}
  end

  def directory_sizes(structure) do
    structure
    |> Enum.reduce({0, []}, fn {id, data}, {current_size, path_sizes} ->
      case data do
        number when is_integer(number) ->
          {current_size + number, path_sizes}

        dir ->
          {size, new_paths} = directory_sizes(dir)
          {current_size + size, [{id, size} | path_sizes] ++ new_paths}
      end
    end)
  end

  def task1(input) do
    input
    |> directory_sizes()
    |> elem(1)
    |> Enum.map(fn {_, size} -> size end)
    |> Enum.filter(fn size -> size <= 100_000 end)
    |> Enum.sum()
  end

  def task2(input) do
    {size, path_sizes} =
      input
      |> directory_sizes()

    space_needed = size - (70_000_000 - 30_000_000)

    path_sizes
    |> Enum.map(fn {_, size} -> size end)
    |> Enum.filter(fn size -> size >= space_needed end)
    |> Enum.sort()
    |> List.first()
  end
end

input = AOC2022.Day7.import("input_day07.txt")

input
|> AOC2022.Day7.task1()
|> IO.puts()

input
|> AOC2022.Day7.task2()
|> IO.puts()
