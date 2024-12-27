defmodule AoC.Year2020.Day8 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_program()
  end

  defp convert_to_instruction(string) do
    [cmd, value] = String.split(string, " ")

    case cmd do
      "acc" ->
        {{:acc, String.to_integer(value)}, 0}

      "jmp" ->
        {{:jmp, String.to_integer(value)}, 0}

      "nop" ->
        {{:nop, String.to_integer(value)}, 0}
    end
  end

  defp convert_to_program(list) do
    {Enum.map(list, &convert_to_instruction(&1)), [], 0}
  end

  defp jump([], previous, _steps), do: {[], previous}
  defp jump(comming, previous, 0), do: {comming, previous}

  defp jump([cmd | rest], previous, steps) do
    jump(rest, [cmd | previous], steps - 1)
  end

  defp run({[], _rest, accumlator}, _halt), do: {accumlator, :normal}

  defp run({[instruction | rest], previous, accumlator}, halt) do
    {{cmd, value}, counter} = instruction

    cond do
      counter == halt ->
        {accumlator, :infinite_loop}

      true ->
        case cmd do
          :acc ->
            accumlator = accumlator + value
            run({rest, [{{cmd, value}, counter + 1} | previous], accumlator}, halt)

          :nop ->
            run({rest, [{{cmd, value}, counter + 1} | previous], accumlator}, halt)

          :jmp ->
            comming_commands = rest
            previous_commands = [{{cmd, value}, counter + 1} | previous]

            {comming_commands, previous_commands} =
              if value > 0 do
                jump(comming_commands, previous_commands, value - 1)
              else
                {previous_commands, comming_commands} = jump(previous_commands, comming_commands, abs(value) + 1)
                {comming_commands, previous_commands}
              end

            run({comming_commands, previous_commands, accumlator}, halt)

          _ ->
            :unknown_cmd
        end
    end
  end

  defp possible_programs({[], _prev, _acc}, _front_program, all_programs), do: all_programs

  defp possible_programs({[instruction | rest], prev, acc}, front_program, all_programs) do
    {{cmd, value}, counter} = instruction

    case cmd do
      :jmp ->
        possible_programs({rest, prev, acc}, [instruction | front_program], [
          {Enum.reverse(front_program) ++ [{{:nop, value}, counter} | rest], prev, acc} | all_programs
        ])

      :nop ->
        possible_programs({rest, prev, acc}, [instruction | front_program], [
          {Enum.reverse(front_program) ++ [{{:jmp, value}, counter} | rest], prev, acc} | all_programs
        ])

      _ ->
        possible_programs({rest, prev, acc}, [instruction | front_program], all_programs)
    end
  end

  def task1(program) do
    program
    |> run(1)
    |> elem(0)
  end

  def task2(program) do
    possible_programs(program, [], [])
    |> Enum.find_value(fn prog ->
      {value, halt_method} = run(prog, 1)

      if halt_method == :normal do
        value
      end
    end)
  end
end

# program = AoC.Year2020.Day8.import("input/2020/input_day08.txt")

# program
# |> AoC.Year2020.Day8.task1()
# |> IO.puts()

# program
# |> AoC.Year2020.Day8.task2()
# |> IO.puts()
