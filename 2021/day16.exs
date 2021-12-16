defmodule Day16 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(fn x ->
      x
      |> String.to_integer(16)
      |> Integer.digits(2)
      |> to_size_of_four()
    end)
    |> List.flatten()
    |> parse_transmission()
  end

  defp to_size_of_four(list) do
    case rem(Enum.count(list), 4) == 0 do
      true ->
        list

      false ->
        to_size_of_four([0 | list])
    end
  end

  defp get_literal([0, a, b, c, d | rest]), do: {[a, b, c, d], rest}

  defp get_literal([1, a, b, c, d | rest]) do
    {result, list} = get_literal(rest)
    {[a, b, c, d | result], list}
  end

  defp get_next_subpacket([]), do: raise("no subpacket")

  defp get_next_subpacket(list) do
    {version, rest} = Enum.split(list, 3)

    version =
      version
      |> Integer.undigits(2)

    {type, rest} = Enum.split(rest, 3)

    type =
      type
      |> Integer.undigits(2)

    case type do
      4 ->
        {literal, rest} = get_literal(rest)

        literal =
          literal
          |> Integer.undigits(2)

        {%{version: version, type: type, literal: literal}, rest}

      _ ->
        [length_type | rest] = rest

        case length_type do
          0 ->
            {subpacket_size, rest} = Enum.split(rest, 15)

            subpacket_size =
              subpacket_size
              |> Integer.undigits(2)

            {subpackets, rest} = Enum.split(rest, subpacket_size)

            subpackets = parse_transmission(subpackets)
            {%{version: version, type: type, subpackets: subpackets}, rest}

          1 ->
            {number_subpackets, rest} = Enum.split(rest, 11)

            number_subpackets =
              number_subpackets
              |> Integer.undigits(2)

            {subpackets, rest} =
              Stream.unfold(0, &{&1, &1 + 1})
              |> Enum.reduce_while({[], rest}, fn itteration, acc = {subpackets, rest} ->
                case itteration < number_subpackets do
                  true ->
                    {subpacket, rest} = get_next_subpacket(rest)

                    {:cont, {[subpacket | subpackets], rest}}

                  false ->
                    {:halt, acc}
                end
              end)

            {%{version: version, type: type, subpackets: Enum.reverse(subpackets)}, rest}
        end
    end
  end

  defp parse_transmission([]), do: []
  defp parse_transmission([0]), do: []
  defp parse_transmission([0, 0]), do: []
  defp parse_transmission([0, 0, 0]), do: []

  defp parse_transmission(list) do
    {packet, rest} = get_next_subpacket(list)
    [packet | parse_transmission(rest)]
  end

  defp sum_version([]), do: 0

  defp sum_version([a | rest]) do
    sum_version(a) + sum_version(rest)
  end

  defp sum_version(%{version: version, subpackets: subpackets}) do
    version + sum_version(subpackets)
  end

  defp sum_version(%{version: version}), do: version

  defp value([]), do: []

  defp value([a | rest]) do
    [value(a) | value(rest)]
  end

  defp value(%{type: 4, literal: literal}), do: literal

  defp value(%{type: 0, subpackets: subpackets}) do
    value(subpackets)
    |> Enum.sum()
  end

  defp value(%{type: 1, subpackets: subpackets}) do
    value(subpackets)
    |> Enum.reduce(&Kernel.*/2)
  end

  defp value(%{type: 2, subpackets: subpackets}) do
    value(subpackets)
    |> Enum.min()
  end

  defp value(%{type: 3, subpackets: subpackets}) do
    value(subpackets)
    |> Enum.max()
  end

  defp value(%{type: 5, subpackets: subpackets}) do
    [a, b] = value(subpackets)

    case a > b do
      true ->
        1

      false ->
        0
    end
  end

  defp value(%{type: 6, subpackets: subpackets}) do
    [a, b] = value(subpackets)

    case a < b do
      true ->
        1

      false ->
        0
    end
  end

  defp value(%{type: 7, subpackets: subpackets}) do
    [a, b] = value(subpackets)

    case a == b do
      true ->
        1

      false ->
        0
    end
  end

  def task1(input) do
    input
    |> sum_version()
  end

  def task2(input) do
    input
    |> value()
    |> List.first()
  end
end

input = Day16.import("input_day16.txt")

input
|> Day16.task1()
|> IO.puts()

input
|> Day16.task2()
|> IO.puts()
