defmodule AoC.Year2022.Day11 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n\n", trim: true)
    |> Enum.map(&convert_to_monkey/1)
    |> Enum.reduce(%{}, fn {monkey, items, operation, control, _to_true, _to_false, divisor}, acc ->
      Map.put(acc, monkey, %{
        items: {items, []},
        operation: operation,
        control: control,
        inspections: 0,
        divisor: divisor
      })
    end)
  end

  defp convert_to_monkey(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.trim()
      |> String.split([" ", ":"])
    end)
    |> Enum.reverse()
    |> Enum.reduce({nil, nil, nil, nil, nil, nil, nil}, fn input, {monkey, items, operation, control, to_true, to_false, divisor} ->
      case input do
        ["Monkey", monkey_number | _] ->
          {String.to_integer(monkey_number), items, operation, control, to_true, to_false, divisor}

        ["Starting", "items", "" | items_input] ->
          items =
            items_input
            |> Enum.map(fn str ->
              str
              |> String.replace(",", "")
              |> String.to_integer()
            end)

          {monkey, items, operation, control, to_true, to_false, divisor}

        ["Operation", "", "new", "=", a, op, b] ->
          operation =
            case op do
              "+" ->
                fn n -> value_or_var(a).(n) + value_or_var(b).(n) end

              "*" ->
                fn n -> value_or_var(a).(n) * value_or_var(b).(n) end
            end

          {monkey, items, operation, control, to_true, to_false, divisor}

        ["Test", "", "divisible", "by", number] ->
          control = fn n ->
            if rem(n, String.to_integer(number)) == 0 do
              to_true
            else
              to_false
            end
          end

          {monkey, items, operation, control, to_true, to_false, String.to_integer(number)}

        ["If", "true", "", "throw", "to", "monkey", number] ->
          to_true = String.to_integer(number)
          {monkey, items, operation, control, to_true, to_false, divisor}

        ["If", "false", "", "throw", "to", "monkey", number] ->
          to_false = String.to_integer(number)
          {monkey, items, operation, control, to_true, to_false, divisor}

        _ ->
          {monkey, items, operation, control, to_true, to_false, divisor}
      end
    end)
  end

  defp value_or_var("old"), do: fn n -> n end
  defp value_or_var(number), do: fn _ -> String.to_integer(number) end

  def play_round(monkeys, with_modulo \\ false) do
    Map.keys(monkeys)
    |> Enum.sort()
    |> Enum.reduce(monkeys, fn monkey, acc ->
      monkey_info = Map.get(acc, monkey)

      operation = Map.get(monkey_info, :operation)
      control = Map.get(monkey_info, :control)

      {front, back} = Map.get(monkey_info, :items)
      acc = put_in(acc, [monkey, :items], {[], []})

      (front ++ Enum.reverse(back))
      |> Enum.reduce(acc, fn number, acc2 ->
        new_number =
          if with_modulo,
            do: rem(operation.(number), with_modulo),
            else: div(operation.(number), 3)

        new_monkey = control.(new_number)
        {front, back} = get_in(acc2, [new_monkey, :items])
        inspections = get_in(acc2, [monkey, :inspections])

        acc2
        |> put_in([new_monkey, :items], {front, [new_number | back]})
        |> put_in([monkey, :inspections], inspections + 1)
      end)
    end)
  end

  def task1(input) do
    1..20
    |> Enum.reduce(input, fn _, acc ->
      play_round(acc)
    end)
    |> Enum.map(fn {_, %{inspections: inspections}} -> inspections end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(2)
    |> Enum.product()
  end

  def task2(input) do
    modulo =
      input
      |> Enum.map(fn {_, %{divisor: divisor}} -> divisor end)
      |> Enum.product()

    1..10_000
    |> Enum.reduce(input, fn _, acc ->
      play_round(acc, modulo)
    end)
    |> Enum.map(fn {_, %{inspections: inspections}} -> inspections end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(2)
    |> Enum.product()
  end
end

input = AoC.Year2022.Day11.import("input/2022/input_day11.txt")

input
|> AoC.Year2022.Day11.task1()
|> IO.puts()

input
|> AoC.Year2022.Day11.task2()
|> IO.puts()
