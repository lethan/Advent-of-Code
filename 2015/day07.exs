defmodule AOC2015.Day7 do
  defmodule LogicGates do
    defmacro __using__(opts) do
      default_opts = [file: nil, signal_size: 16, except: []]
      opts = Keyword.merge(default_opts, opts)

      bitpattern = Bitwise.<<<(1, Keyword.fetch!(opts, :signal_size)) - 1

      file_definitions = gates_from_file(Keyword.get(opts, :file), Keyword.get(opts, :except, []))

      quote do
        import unquote(__MODULE__)

        @before_compile unquote(__MODULE__)

        @bitpattern unquote(bitpattern)

        unquote(file_definitions)
      end
    end

    defmacro __before_compile__(_env) do
      quote do
        def a &&& b do
          Bitwise.&&&(a, b)
          |> Bitwise.&&&(@bitpattern)
        end

        def a ||| b do
          Bitwise.|||(a, b)
          |> Bitwise.&&&(@bitpattern)
        end

        def a >>> b do
          Bitwise.>>>(a, b)
          |> Bitwise.&&&(@bitpattern)
        end

        def a <<< b do
          Bitwise.<<<(a, b)
          |> Bitwise.&&&(@bitpattern)
        end

        def ~~~a do
          Bitwise.~~~(a)
          |> Bitwise.&&&(@bitpattern)
        end
      end
    end

    defp generate_blocks(value) when is_integer(value) do
      quote do
        {unquote(value), memorized}
      end
    end

    defp generate_blocks(gate) when is_binary(gate) do
      function_name = String.to_atom(gate)

      quote do
        unquote(function_name)(memorized)
      end
    end

    defp generate_blocks([value]) do
      generate_blocks(value)
    end

    defp generate_blocks([:~~~, value]) do
      quote do
        {value, memorized} = unquote(generate_blocks(value))
        {~~~value, memorized}
      end
    end

    defp generate_blocks([lhs, operator, rhs]) when operator in [:&&&, :|||, :<<<, :>>>] do
      quote do
        {left_value, memorized} = unquote(generate_blocks(lhs))
        {right_value, memorized} = unquote(generate_blocks(rhs))
        {apply(__MODULE__, unquote(operator), [left_value, right_value]), memorized}
      end
    end

    defp input_to_type(input) do
      case Integer.parse(input) do
        {value, ""} ->
          value

        _ ->
          case input do
            "AND" ->
              :&&&

            "OR" ->
              :|||

            "LSHIFT" ->
              :<<<

            "RSHIFT" ->
              :>>>

            "NOT" ->
              :~~~

            value ->
              "gate_#{value}"
          end
      end
    end

    defp gates_from_file(nil, _except), do: nil

    defp gates_from_file(file, except) do
      gates_file = Path.join(__DIR__, file)

      ast =
        for line <- File.stream!(gates_file, [], :line) do
          [input, gate] = line |> String.split(" -> ") |> Enum.map(&String.trim/1)
          gate_function = input_to_type(gate) |> String.to_atom()
          gate = String.to_atom(gate)

          block = input |> String.split(" ") |> Enum.map(&input_to_type/1)

          included =
            unless gate in except do
              quote do
                defp unquote(gate_function)(memorized = %{unquote(gate_function) => value}) do
                  {value, memorized}
                end

                defp unquote(gate_function)(memorized) do
                  {value, new_memorized} = unquote(generate_blocks(block))
                  new_memorized = Map.put(new_memorized, unquote(gate_function), value)
                  {value, new_memorized}
                end
              end
            end

          quote do
            def gate_value(unquote(gate)) do
              {value, _memorized} = unquote(gate_function)(%{})
              value
            end

            unquote(included)
          end
        end

      quote do
        @external_resource unquote(gates_file)

        unquote(ast)
      end
    end
  end

  defmodule Task1 do
    use LogicGates, file: "input_day07.txt"
  end

  defmodule Task2 do
    use LogicGates, file: "input_day07.txt", except: [:b]

    defp gate_b(memorized = %{gate_b: value}) do
      {value, memorized}
    end

    defp gate_b(memorized) do
      b = Task1.gate_value(:a)
      new_memorized = Map.put(memorized, :gate_b, b)
      {b, new_memorized}
    end
  end
end

AOC2015.Day7.Task1.gate_value(:a)
|> IO.puts()

AOC2015.Day7.Task2.gate_value(:a)
|> IO.puts()
