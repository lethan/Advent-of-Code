defmodule AoC.Year2015.Day4 do
  defp find_valid_hash_value(input, number_of_zeroes, current_number \\ 1) do
    zeroes = String.duplicate("0", number_of_zeroes)
    test_value = input <> Integer.to_string(current_number)

    result =
      :crypto.hash(:md5, test_value)
      |> Base.encode16()

    cond do
      String.starts_with?(result, zeroes) ->
        current_number

      true ->
        find_valid_hash_value(input, number_of_zeroes, current_number + 1)
    end
  end

  def task1(input) do
    input
    |> find_valid_hash_value(5)
  end

  def task2(input) do
    input
    |> find_valid_hash_value(6)
  end
end

# input = "bgvyzdsv"

# input
# |> AoC.Year2015.Day4.task1()
# |> IO.puts()

# input
# |> AoC.Year2015.Day4.task2()
# |> IO.puts()
