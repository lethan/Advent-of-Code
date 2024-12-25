defmodule AoC.Year2020.Day4 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n")
    |> remove_last_empty()
    |> Enum.reduce([[]], &compiler/2)
    |> Enum.map(&convert_to_map/1)
  end

  defp compiler("", acc), do: [[] | acc]

  defp compiler(string, [first | rest]) do
    inserts =
      string
      |> String.split([" ", ":"])

    [inserts ++ first | rest]
  end

  defp convert_to_map(list) do
    list
    |> Enum.chunk_every(2)
    |> Map.new(fn [k, v] -> {k, v} end)
  end

  defp remove_last_empty(list) do
    list
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 == ""))
    |> Enum.reverse()
  end

  defp validate_byr(%{"byr" => value}) do
    year = String.to_integer(value)

    cond do
      year >= 1920 and year <= 2002 ->
        :ok

      true ->
        nil
    end
  end

  defp validate_byr(_), do: nil

  defp validate_iyr(%{"iyr" => value}) do
    year = String.to_integer(value)

    cond do
      year >= 2010 and year <= 2020 ->
        :ok

      true ->
        nil
    end
  end

  defp validate_iyr(_), do: nil

  defp validate_eyr(%{"eyr" => value}) do
    year = String.to_integer(value)

    cond do
      year >= 2020 and year <= 2030 ->
        :ok

      true ->
        nil
    end
  end

  defp validate_eyr(_), do: nil

  defp validate_hgt(%{"hgt" => value}) do
    {height, unit} = String.split_at(value, -2)
    height = String.to_integer(height)

    case unit do
      "in" ->
        if height >= 59 and height <= 76 do
          :ok
        else
          nil
        end

      "cm" ->
        if height >= 150 and height <= 193 do
          :ok
        else
          nil
        end

      _ ->
        nil
    end
  end

  defp validate_hgt(_), do: nil

  defp validate_hcl(%{"hcl" => value}) do
    if String.match?(value, ~r/^#[0-9a-f]{6}$/) do
      :ok
    else
      nil
    end
  end

  defp validate_hcl(_), do: nil

  defp validate_ecl(%{"ecl" => value}) do
    if Enum.find(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], &(&1 == value)) do
      :ok
    else
      nil
    end
  end

  defp validate_ecl(_), do: nil

  defp validate_pid(%{"pid" => value}) do
    if String.match?(value, ~r/^[0-9]{9}$/) do
      :ok
    else
      nil
    end
  end

  defp validate_pid(_), do: nil

  def task1(input) do
    input
    |> Enum.filter(fn passport ->
      case passport do
        %{"byr" => _, "iyr" => _, "eyr" => _, "hgt" => _, "hcl" => _, "ecl" => _, "pid" => _} ->
          true

        _ ->
          false
      end
    end)
    |> Enum.count()
  end

  def task2(input) do
    input
    |> Enum.filter(fn passport ->
      with :ok <- validate_byr(passport),
           :ok <- validate_iyr(passport),
           :ok <- validate_eyr(passport),
           :ok <- validate_hgt(passport),
           :ok <- validate_hcl(passport),
           :ok <- validate_ecl(passport),
           :ok <- validate_pid(passport),
           do: :ok
    end)
    |> Enum.count()
  end
end

# input = AoC.Year2020.Day4.import("input/2020/input_day04.txt")

# input
# |> AoC.Year2020.Day4.task1()
# |> IO.puts()

# input
# |> AoC.Year2020.Day4.task2()
# |> IO.puts()
