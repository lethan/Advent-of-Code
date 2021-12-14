defmodule AOC2015.Day8 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp decode_size([]), do: {0, -2}

  defp decode_size(["\\", "x", _, _ | rest]) do
    {original_size, decode_size} = decode_size(rest)
    {original_size + 4, decode_size + 1}
  end

  defp decode_size(["\\", a | rest]) when a in ["\"", "\\"] do
    {original_size, decode_size} = decode_size(rest)
    {original_size + 2, decode_size + 1}
  end

  defp decode_size([_ | rest]) do
    {original_size, decode_size} = decode_size(rest)
    {original_size + 1, decode_size + 1}
  end

  defp encode_size([]), do: {0, 2}

  defp encode_size([a | rest]) when a in ["\\", "\""] do
    {original_size, encode_size} = encode_size(rest)
    {original_size + 1, encode_size + 2}
  end

  defp encode_size([_ | rest]) do
    {original_size, encode_size} = encode_size(rest)
    {original_size + 1, encode_size + 1}
  end

  def task1(input) do
    {original_size, decode_size} =
      input
      |> Enum.reduce({0, 0}, fn list, {original_size, decode_size} ->
        {list_org_size, list_decode_size} = decode_size(list)
        {original_size + list_org_size, decode_size + list_decode_size}
      end)

    original_size - decode_size
  end

  def task2(input) do
    {original_size, encode_size} =
      input
      |> Enum.reduce({0, 0}, fn list, {original_size, encode_size} ->
        {list_org_size, list_encode_size} = encode_size(list)
        {original_size + list_org_size, encode_size + list_encode_size}
      end)

    encode_size - original_size
  end
end

input = AOC2015.Day8.import("input_day08.txt")

input
|> AOC2015.Day8.task1()
|> IO.puts()

input
|> AOC2015.Day8.task2()
|> IO.puts()
