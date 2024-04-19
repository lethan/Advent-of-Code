defmodule AoC.Year2015.Day7 do
  defmodule LogicGates do
    defmacro __using__(opts) do
      default_opts = [file: nil, signal_size: 16, except: []]
      opts = Keyword.merge(default_opts, opts)

      bitpattern = Bitwise.<<<(1, Keyword.fetch!(opts, :signal_size)) - 1

      Module.register_attribute(__CALLER__.module, :gate, accumulate: true, persist: false)

      gate_defs = register_gates(Keyword.get(opts, :file), Keyword.get(opts, :except, []))

      quote do
        @before_compile unquote(__MODULE__)

        @bitpattern unquote(bitpattern)

        unquote(gate_defs)
      end
    end

    defmacro __before_compile__(env) do
      gates =
        Module.get_attribute(env.module, :gate)
        |> Enum.into(%{})

      bitpattern = Module.get_attribute(env.module, :bitpattern) || 1

      {output, _} =
        Enum.reduce(Map.keys(gates), {[], gates}, fn gate, {acc, gates} ->
          {value, gates} = gate_value(gate, gates, bitpattern)

          fun =
            quote generated: true do
              def gate_value(unquote(gate)), do: unquote(value)
            end

          {[fun | acc], gates}
        end)

      output
    end

    #@dialyzer {:nowarn_function, value: 3}
    def value({:value, value}, gates, _) do
      {value, gates}
    end

    def value({:gate, gate}, gates, bitpattern) do
      {value, new_gates} = gate_value(gate, gates, bitpattern)
      new_gates = Map.put(new_gates, gate, value)
      {value, new_gates}
    end

    #@dialyzer {:nowarn_function, gate_value: 3}
    def gate_value(gate, gates, bitpattern) do
      case Map.get(gates, gate) do
        value when is_integer(value) ->
          {value, gates}

        {:value, value} ->
          gates = Map.put(gates, gate, value)
          {value, gates}

        {:gate, other_gate} ->
          {value, new_gates} = gate_value(other_gate, gates, bitpattern)
          new_gates = Map.put(new_gates, gate, {:value, value})
          {value, new_gates}

        {op, left, right} ->
          {left_value, gates} = value(left, gates, bitpattern)
          {right_value, gates} = value(right, gates, bitpattern)

          value = apply(Bitwise, op, [left_value, right_value]) |> Bitwise.&&&(bitpattern)
          gates = Map.put(gates, gate, value)
          {value, gates}

        {:~~~, left} ->
          {left_value, gates} = value(left, gates, bitpattern)

          value = Bitwise.~~~(left_value) |> Bitwise.&&&(bitpattern)
          gates = Map.put(gates, gate, value)
          {value, gates}
      end
    end

    defp register_gates(nil, _except), do: nil

    defp register_gates(file, except) do
      gates_file = Path.join([__DIR__, "../../", file]) |> Path.expand()

      ast =
        for line <- File.stream!(gates_file, [], :line) do
          [input, gate] = line |> String.split(" -> ") |> Enum.map(&String.trim/1)
          gate = String.to_atom(gate)

          block = input |> String.split(" ") |> Enum.map(&input_to_type/1) |> block_to_data()

          unless gate in except do
            quote location: :keep, generated: true do
              @gate unquote(Macro.escape({gate, block}))
            end
          end
        end

      quote do
        @external_resource unquote(gates_file)

        unquote(ast)
      end
    end

    defp block_to_data([a]), do: a
    defp block_to_data([neg, a]), do: {neg, a}
    defp block_to_data([a, op, b]), do: {op, a, b}

    defp input_to_type("AND"), do: :&&&
    defp input_to_type("OR"), do: :|||
    defp input_to_type("LSHIFT"), do: :<<<
    defp input_to_type("RSHIFT"), do: :>>>
    defp input_to_type("NOT"), do: :~~~

    defp input_to_type(input) do
      case Integer.parse(input) do
        {value, ""} ->
          {:value, value}

        _ ->
          {:gate, String.to_atom(input)}
      end
    end
  end

  defmodule Task1 do
    use LogicGates, file: "input/2015/input_day07.txt"
  end

  defmodule Task2 do
    use LogicGates, file: "input/2015/input_day07.txt", except: [:b]

    @gate {:b, {:value, Task1.gate_value(:a)}}
  end
end

# AoC.Year2015.Day7.Task1.gate_value(:a)
# |> IO.puts()

# AoC.Year2015.Day7.Task2.gate_value(:a)
# |> IO.puts()
