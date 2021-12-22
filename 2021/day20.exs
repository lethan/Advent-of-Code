defmodule Day20 do
  def import(file) do
    {:ok, content} = File.read(file)

    [algorithm, image] =
      content
      |> String.split("\n\n", trim: true)

    algorithm = convert_to_algorithm(algorithm)

    image = convert_to_image(image)

    {algorithm, image}
  end

  defp convert_to_algorithm(string) do
    {map, _} =
      string
      |> String.graphemes()
      |> Enum.reduce({%{}, 0}, fn x, {acc, next_index} ->
        value =
          case x do
            "." ->
              0

            "#" ->
              1
          end

        acc = Map.put(acc, next_index, value)
        {acc, next_index + 1}
      end)

    default_pixel = 0
    next_pixel = map[0]

    index =
      Stream.cycle([next_pixel])
      |> Stream.take(9)
      |> Enum.to_list()
      |> Integer.undigits(2)

    after_pixel = map[index]

    next_pixel_function = get_next_default_pixel_function(next_pixel, after_pixel)
    {map, default_pixel, next_pixel_function}
  end

  defp get_next_default_pixel_function(next_pixel, after_pixel) when next_pixel == after_pixel do
    fn _ -> next_pixel end
  end

  defp get_next_default_pixel_function(next_pixel, after_pixel) do
    fn
      ^next_pixel -> after_pixel
      ^after_pixel -> next_pixel
    end
  end

  defp convert_to_image(string) do
    {image, max_y, max_x} =
      string
      |> String.split("\n", trim: true)
      |> Enum.reduce({%{}, 0, nil}, fn string, {acc, line, _} ->
        {acc, max_x} =
          string
          |> String.graphemes()
          |> Enum.reduce({acc, 0}, fn char, {acc2, column} ->
            value =
              case char do
                "." ->
                  0

                "#" ->
                  1
              end

            acc2 = Map.put(acc2, {column, line}, value)
            {acc2, column + 1}
          end)

        {acc, line + 1, max_x - 1}
      end)

    {image, 0, max_x, 0, max_y - 1}
  end

  defp get_new_pixel(x, y, image, map, default_pixel) do
    index =
      Enum.reduce((y - 1)..(y + 1), [], fn y, acc ->
        Enum.reduce((x - 1)..(x + 1), acc, fn x, acc2 ->
          [Map.get(image, {x, y}, default_pixel) | acc2]
        end)
      end)
      |> Enum.reverse()
      |> Integer.undigits(2)

    map[index]
  end

  defp on_pixels({_, {image, _, _, _, _}}) do
    image
    |> Enum.reduce(0, fn {_, value}, acc ->
      if value == 1, do: acc + 1, else: acc
    end)
  end

  defp enhance_image({{map, default_pixel, next_default}, {image, min_x, max_x, min_y, max_y}}) do
    new_image =
      for(
        x <- (min_x - 1)..(max_x + 1),
        y <- (min_y - 1)..(max_y + 1),
        do: {x, y}
      )
      |> Enum.reduce(%{}, fn coord = {x, y}, acc ->
        Map.put(acc, coord, get_new_pixel(x, y, image, map, default_pixel))
      end)

    algorithm = {map, next_default.(default_pixel), next_default}
    image = {new_image, min_x - 1, max_x + 1, min_y - 1, max_y + 1}
    {algorithm, image}
  end

  def task1(input) do
    input
    |> enhance_image()
    |> enhance_image()
    |> on_pixels()
  end

  def task2(input) do
    1..50
    |> Enum.reduce(input, fn _, acc ->
      enhance_image(acc)
    end)
    |> on_pixels()
  end
end

input = Day20.import("input_day20.txt")

input
|> Day20.task1()
|> IO.puts()

input
|> Day20.task2()
|> IO.puts()
