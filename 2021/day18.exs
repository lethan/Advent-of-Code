defmodule Day18 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> convert_to_data()
  end

  defp convert_to_data(list) do
    list
    |> Enum.map(&parse_snailfish/1)
  end

  def parse_snailfish("[" <> rest) do
    {first, rest} = find_snailfish_subcontent(rest, "")
    {second, ""} = find_snailfish_subcontent(rest, "")
    {first, second}
  end

  def find_snailfish_subcontent("," <> rest, number) when is_binary(number) do
    {String.to_integer(number), rest}
  end

  def find_snailfish_subcontent("," <> rest, acc), do: {acc, rest}

  def find_snailfish_subcontent("]" <> rest, number) when is_binary(number) do
    {String.to_integer(number), rest}
  end

  def find_snailfish_subcontent("]" <> rest, acc), do: {acc, rest}

  def find_snailfish_subcontent("[" <> rest, _acc) do
    {first, rest} = find_snailfish_subcontent(rest, "")
    {second, rest} = find_snailfish_subcontent(rest, "")
    find_snailfish_subcontent(rest, {first, second})
  end

  def find_snailfish_subcontent(<<intchar::binary-1>> <> rest, acc) do
    find_snailfish_subcontent(rest, acc <> intchar)
  end

  def add_snailfish(a, b), do: reduce_snailfish({a, b})

  def reduce_snailfish(tree) do
    {changed, tree} =
      case explode_snailfish(tree) do
        {true, tree, _, _} ->
          {true, tree}

        {false, tree, _, _} ->
          split_snailfish(tree)
      end

    if changed do
      reduce_snailfish(tree)
    else
      tree
    end
  end

  def explode_snailfish(tree, depth \\ 0)

  def explode_snailfish({a, b}, 4) do
    {true, 0, a, b}
  end

  def explode_snailfish({a, b}, depth) do
    case explode_snailfish(a, depth + 1) do
      {true, a, left, right} ->
        if is_integer(right) do
          {true, {a, inc_left(b, right)}, left, nil}
        else
          {true, {a, b}, left, right}
        end

      {false, a, _, _} ->
        case explode_snailfish(b, depth + 1) do
          {false, b, left, right} ->
            {false, {a, b}, left, right}

          {true, b, left, right} ->
            if is_integer(left) do
              {true, {inc_right(a, left), b}, nil, right}
            else
              {true, {a, b}, left, right}
            end
        end
    end
  end

  def explode_snailfish(number, _depth), do: {false, number, nil, nil}

  def inc_left({a, b}, value), do: {inc_left(a, value), b}
  def inc_left(number, value), do: number + value

  def inc_right({a, b}, value), do: {a, inc_right(b, value)}
  def inc_right(number, value), do: number + value

  def split_snailfish({a, b}) do
    case split_snailfish(a) do
      {true, a} ->
        {true, {a, b}}

      {false, a} ->
        {changed, b} = split_snailfish(b)
        {changed, {a, b}}
    end
  end

  def split_snailfish(number) when number >= 10 do
    {true, {div(number, 2), div(number + 1, 2)}}
  end

  def split_snailfish(number), do: {false, number}

  def magnitude_snailmail({a, b}) do
    3 * magnitude_snailmail(a) + 2 * magnitude_snailmail(b)
  end

  def magnitude_snailmail(value), do: value

  def task1(input) do
    input
    |> Enum.reduce(&add_snailfish(&2, &1))
    |> magnitude_snailmail()
  end

  def task2(input) do
    for(a <- input, b <- input, a != b, do: {a, b})
    |> Enum.map(fn {a, b} ->
      add_snailfish(a, b)
      |> magnitude_snailmail()
    end)
    |> Enum.sort(:desc)
    |> List.first()
  end
end

input = Day18.import("input_day18.txt")

input
|> Day18.task1()
|> IO.puts()

input
|> Day18.task2()
|> IO.puts()
