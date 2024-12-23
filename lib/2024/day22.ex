defmodule AoC.Year2024.Day22 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp prune(value), do: rem(value, 16_777_216)

  defp mix(value, secret), do: Bitwise.bxor(value, secret)

  defp next_secret(secret) do
    secret =
      secret
      |> Kernel.*(64)
      |> mix(secret)
      |> prune()

    secret =
      secret
      |> div(32)
      |> mix(secret)
      |> prune()

    secret
    |> Kernel.*(2048)
    |> mix(secret)
    |> prune()
  end

  defp nth_secret(secret, n) do
    1..n
    |> Enum.reduce(secret, fn _, acc ->
      next_secret(acc)
    end)
  end

  def change_values(secret, n) do
    1..n
    |> Enum.reduce({%{}, secret, {nil, nil, nil}}, fn _, {map, secret, {a, b, c}} ->
      new_secret = next_secret(secret)
      new_value = rem(new_secret, 10)
      old_value = rem(secret, 10)
      diff = new_value - old_value

      map = if is_nil(a) or diff < 0, do: map, else: Map.put_new(map, {a, b, c, diff}, new_value)
      {map, new_secret, {b, c, diff}}
    end)
    |> elem(0)
  end

  def task1(input) do
    input
    |> Enum.map(&nth_secret(&1, 2000))
    |> Enum.sum()
  end

  def task2(input) do
    input
    |> Enum.map(&change_values(&1, 2000))
    |> Enum.reduce(fn map, acc ->
      Map.merge(map, acc, fn _, v1, v2 -> v1 + v2 end)
    end)
    |> Enum.max_by(fn {_, v} -> v end)
    |> elem(1)
  end
end

# input = AoC.Year2024.Day22.import("input/2024/input_day22.txt")

# input
# |> AoC.Year2024.Day22.task1()
# |> IO.puts()

# input
# |> AoC.Year2024.Day22.task2()
# |> IO.puts()
