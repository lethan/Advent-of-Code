defmodule AOC2022.Day21 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn str, acc ->
      [monkey, value] =
        str
        |> String.split(": ", trim: true)

      value =
        case String.split(value) do
          [number] ->
            String.to_integer(number)

          [first, operation, second] ->
            operation =
              case operation do
                "+" -> &Kernel.+/2
                "-" -> &Kernel.-/2
                "*" -> &Kernel.*/2
                "/" -> &Kernel.div/2
              end

            %{monkey1: first, monkey2: second, operation: operation}
        end

      Map.put(acc, monkey, value)
    end)
  end

  def monkey_value(monkey, monkey_values) do
    case Map.get(monkey_values, monkey) do
      number when is_integer(number) ->
        {number, monkey_values}

      %{monkey1: monkey1, monkey2: monkey2, operation: operation} ->
        {monkey1_value, new_monkey_values} = monkey_value(monkey1, monkey_values)
        {monkey2_value, new_monkey_values} = monkey_value(monkey2, new_monkey_values)

        if monkey1_value == :unknown or monkey2_value == :unknown do
          {:unknown, new_monkey_values}
        else
          value = operation.(monkey1_value, monkey2_value)
          monkey_values = Map.put(new_monkey_values, monkey, value)
          {value, monkey_values}
        end

      :unknown ->
        {:unknown, monkey_values}
    end
  end

  def needed_value(monkey, monkey_values, needed_value \\ true) do
    case Map.get(monkey_values, monkey) do
      :unknown ->
        needed_value

      number when is_integer(number) ->
        needed_value == number

      %{monkey1: monkey1, monkey2: monkey2, operation: operation} ->
        {monkey1_value, new_monkey_values} = monkey_value(monkey1, monkey_values)
        {monkey2_value, new_monkey_values} = monkey_value(monkey2, new_monkey_values)

        case {monkey1_value, monkey2_value, operation_type(operation)} do
          {:unknown, value, :plus} ->
            needed_value(monkey1, new_monkey_values, needed_value - value)

          {value, :unknown, :plus} ->
            needed_value(monkey2, new_monkey_values, needed_value - value)

          {:unknown, value, :minus} ->
            needed_value(monkey1, new_monkey_values, needed_value + value)

          {value, :unknown, :minus} ->
            needed_value(monkey2, new_monkey_values, -(needed_value - value))

          {:unknown, value, :multiply} ->
            needed_value(monkey1, new_monkey_values, div(needed_value, value))

          {value, :unknown, :multiply} ->
            needed_value(monkey2, new_monkey_values, div(needed_value, value))

          {:unknown, value, :div} ->
            needed_value(monkey1, new_monkey_values, needed_value * value)

          {value, :unknown, :div} ->
            needed_value(monkey2, new_monkey_values, div(value, needed_value))

          {:unknown, value, :equal} ->
            needed_value(monkey1, new_monkey_values, value)

          {value, :unknown, :multiply} ->
            needed_value(monkey2, new_monkey_values, value)
        end
    end
  end

  defp operation_type(operation) do
    cond do
      operation.(6, 3) == 9 ->
        :plus

      operation.(6, 3) == 3 ->
        :minus

      operation.(6, 3) == 2 ->
        :div

      operation.(6, 3) == 18 ->
        :multiply

      operation.(1, 1) == true ->
        :equal
    end
  end

  def task1(input) do
    monkey_value("root", input)
    |> elem(0)
  end

  def task2(input) do
    input =
      input
      |> put_in(["root", :operation], &Kernel.==/2)
      |> put_in(["humn"], :unknown)

    needed_value("root", input)
  end
end

input = AOC2022.Day21.import("input_day21.txt")

input
|> AOC2022.Day21.task1()
|> IO.puts()

input
|> AOC2022.Day21.task2()
|> IO.puts()
