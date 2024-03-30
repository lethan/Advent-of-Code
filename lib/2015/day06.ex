defmodule AoC.Year2015.Day6 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&convert_to_data/1)
  end

  defp convert_to_data(string) do
    [instruction, on_off, x1, y1, x2, y2] =
      Regex.run(
        ~r/(toggle|turn (on|off)) ([0-9]+),([0-9]+) through ([0-9]+),([0-9]+)/,
        string,
        capture: :all_but_first
      )

    instruction =
      case instruction do
        "toggle" ->
          :toggle

        _ ->
          if on_off == "on" do
            :on
          else
            :off
          end
      end

    [x1, y1, x2, y2] =
      [x1, y1, x2, y2]
      |> Enum.map(&String.to_integer/1)

    [x1, x2] = Enum.sort([x1, x2])
    [y1, y2] = Enum.sort([y1, y2])

    {instruction, {{x1, y1}, {x2, y2}}}
  end

  defp intersection({{_a_x1, _a_y1}, {a_x2, _a_y2}} = a, {{b_x1, _b_y1}, {_b_x2, _b_y2}} = b) when a_x2 < b_x1 do
    {[a], [], [b]}
  end

  defp intersection({{a_x1, _a_y1}, {_a_x2, _a_y2}} = a, {{_b_x1, _b_y1}, {b_x2, _b_y2}} = b) when a_x1 > b_x2 do
    {[a], [], [b]}
  end

  defp intersection({{_a_x1, _a_y1}, {_a_x2, a_y2}} = a, {{_b_x1, b_y1}, {_b_x2, _b_y2}} = b) when a_y2 < b_y1 do
    {[a], [], [b]}
  end

  defp intersection({{_a_x1, a_y1}, {_a_x2, _a_y2}} = a, {{_b_x1, _b_y1}, {_b_x2, b_y2}} = b) when a_y1 > b_y2 do
    {[a], [], [b]}
  end

  defp intersection({{a_x1, a_y1}, {a_x2, a_y2}}, {{b_x1, b_y1}, {b_x2, b_y2}}) do
    common = {{cx1, cy1}, {cx2, cy2}} = {{max(a_x1, b_x1), max(a_y1, b_y1)}, {min(a_x2, b_x2), min(a_y2, b_y2)}}

    a_left =
      for(
        xs <- [a_x1..(cx1 - 1)//1, cx1..cx2//1, (cx2 + 1)..a_x2//1],
        ys <- [a_y1..(cy1 - 1)//1, cy1..cy2//1, (cy2 + 1)..a_y2//1],
        xs != cx1..cx2//1 or ys != cy1..cy2//1,
        Range.size(xs) > 0,
        Range.size(ys) > 0
      ) do
        {x1, x2} = Enum.min_max(xs)
        {y1, y2} = Enum.min_max(ys)
        {{x1, y1}, {x2, y2}}
      end

    b_left =
      for(
        xs <- [b_x1..(cx1 - 1)//1, cx1..cx2//1, (cx2 + 1)..b_x2//1],
        ys <- [b_y1..(cy1 - 1)//1, cy1..cy2//1, (cy2 + 1)..b_y2//1],
        xs != cx1..cx2//1 or ys != cy1..cy2//1,
        Range.size(xs) > 0,
        Range.size(ys) > 0
      ) do
        {x1, x2} = Enum.min_max(xs)
        {y1, y2} = Enum.min_max(ys)
        {{x1, y1}, {x2, y2}}
      end

    {a_left, [common], b_left}
  end

  defp on(currently_on, turn_on, checked \\ [])
  defp on(ons, [], checked), do: ons ++ checked
  defp on([], [a | rest], checked), do: on([a | checked], rest)

  defp on([b | ons], [a | rest] = turn_on, checked) do
    case intersection(a, b) do
      {[^a], [], [^b]} ->
        on(ons, turn_on, [b | checked])

      {as, [_], _} ->
        on([b | ons] ++ checked, rest ++ as)
    end
  end

  defp off(currently_on, turn_off, checked \\ [])
  defp off(ons, [], checked), do: ons ++ checked
  defp off([], _, checked), do: checked

  defp off([b | ons], turn_off, checked) do
    turn_off
    |> Enum.reduce_while(:ok, fn rect, :ok ->
      case intersection(rect, b) do
        {[^rect], [], [^b]} ->
          {:cont, :ok}

        {as, [_], bs} ->
          new_turn_off = List.delete(turn_off, rect) ++ as
          new_ons = bs ++ ons
          {:halt, {:retry, new_turn_off, new_ons}}
      end
    end)
    |> case do
      :ok ->
        off(ons, turn_off, [b | checked])

      {:retry, new_turn_off, new_ons} ->
        off(new_ons, new_turn_off, checked)
    end
  end

  defp toggle(currently_on, toggle, checked \\ [])
  defp toggle(ons, [], checked), do: ons ++ checked
  defp toggle([], [a | rest], checked), do: toggle([a | checked], rest)

  defp toggle([b | ons], [a | rest] = toggle, checked) do
    case intersection(a, b) do
      {[^a], [], [^b]} ->
        toggle(ons, toggle, [b | checked])

      {as, [_], bs} ->
        toggle(ons ++ bs ++ checked, rest ++ as)
    end
  end

  defp lit(list) do
    list
    |> Enum.reduce(0, fn {{x1, y1}, {x2, y2}}, acc ->
      acc + (x2 - x1 + 1) * (y2 - y1 + 1)
    end)
  end

  def task1(input) do
    input
    |> Enum.reduce([], fn {instruction, rect}, acc ->
      case instruction do
        :on ->
          on(acc, [rect])

        :off ->
          off(acc, [rect])

        :toggle ->
          toggle(acc, [rect])
      end
    end)
    |> lit
  end

  def task2(input) do
    input
    |> Enum.reduce([], fn {instruction, rect}, acc ->
      case instruction do
        :on ->
          [rect | acc]

        :off ->
          off(acc, [rect])

        :toggle ->
          [rect, rect | acc]
      end
    end)
    |> lit
  end
end

# input = AoC.Year2015.Day6.import("input/2015/input_day06.txt")

# input
# |> AoC.Year2015.Day6.task1()
# |> IO.puts()

# input
# |> AoC.Year2015.Day6.task2()
# |> IO.puts()
