defmodule Day25 do

  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def find_itterations(value, step, _subject, public_key, _modulation) when value == public_key, do: step
  def find_itterations(value, step, subject, public_key, modulation) do
    find_itterations(rem(value * subject, modulation), step+1, subject, public_key, modulation)
  end

  def encrypt(value, 0, _public_key, _modulation), do: value
  def encrypt(value, steps, public_key, modulation) do
    encrypt(rem(value * public_key, modulation), steps - 1, public_key, modulation)
  end

  def task1(input) do
    [key1, key2] = input
    mod = 20201227
    itterations = find_itterations(1, 0, 7, key1, mod)
    encrypt(1, itterations, key2, mod)
  end
end

input = Day25.import("input_day25.txt")

input
|> Day25.task1
|> IO.puts
