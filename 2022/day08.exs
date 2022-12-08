defmodule AOC2022.Day8 do
  def import(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, acc ->
      row
      |> Enum.reduce(acc, fn {value, x}, acc2 ->
        Map.put(acc2, {x, y}, value)
      end)
    end)
  end

  def visible_tree(
        trees,
        coord,
        direction,
        last_tree \\ -1,
        max_height \\ 9,
        always_higher \\ true,
        visible \\ %{}
      )

  def visible_tree(_, _, _, last_tree, max_height, _, visible) when last_tree >= max_height,
    do: visible

  def visible_tree(
        trees,
        {x, y} = coord,
        {x_dir, y_dir} = direction,
        last_tree,
        max_height,
        true,
        visible
      ) do
    case Map.get(trees, coord) do
      nil ->
        visible

      height when height > last_tree ->
        visible = Map.put(visible, coord, true)
        visible_tree(trees, {x + x_dir, y + y_dir}, direction, height, max_height, true, visible)

      _ ->
        visible_tree(
          trees,
          {x + x_dir, y + y_dir},
          direction,
          last_tree,
          max_height,
          true,
          visible
        )
    end
  end

  def visible_tree(
        trees,
        {x, y} = coord,
        {x_dir, y_dir} = direction,
        _last_tree,
        max_height,
        false,
        visible
      ) do
    case Map.get(trees, coord) do
      nil ->
        visible

      height ->
        visible = Map.put(visible, coord, true)
        visible_tree(trees, {x + x_dir, y + y_dir}, direction, height, max_height, false, visible)
    end
  end

  def visible_trees(trees) do
    {min_x, max_x} =
      trees
      |> Enum.map(fn {{x, _}, _val} -> x end)
      |> Enum.min_max()

    {min_y, max_y} =
      trees
      |> Enum.map(fn {{_, y}, _val} -> y end)
      |> Enum.min_max()

    visible =
      for(
        x <- min_x..max_x,
        y <- [min_y, max_y],
        direction <- [1 - 2 * div(y, max_y)],
        do: {{x, y}, {0, direction}}
      )
      |> Enum.reduce(%{}, fn {coord, direction}, acc ->
        visible_tree(trees, coord, direction)
        |> Map.merge(acc)
      end)

    for(
      x <- [min_x, max_x],
      y <- min_y..max_y,
      direction <- [1 - 2 * div(x, max_x)],
      do: {{x, y}, {direction, 0}}
    )
    |> Enum.reduce(%{}, fn {coord, direction}, acc ->
      visible_tree(trees, coord, direction)
      |> Map.merge(acc)
    end)
    |> Map.merge(visible)
  end

  def scenic_trees(trees) do
    trees
    |> Enum.map(fn {{x, y} = coord, tree} ->
      visible_trees =
        for(
          dir_x <- -1..1,
          dir_y <- -1..1,
          dir_x != dir_y,
          dir_x == 0 or dir_y == 0,
          do: {dir_x, dir_y}
        )
        |> Enum.reduce(%{}, fn {dir_x, dir_y} = direction, acc ->
          visible_tree(trees, {x + dir_x, y + dir_y}, direction, -1, tree, false)
          |> Map.merge(acc)
        end)

      {min_x, max_x} =
        visible_trees
        |> Enum.map(fn {{x, _}, _val} -> x end)
        |> Enum.min_max()

      {min_y, max_y} =
        visible_trees
        |> Enum.map(fn {{_, y}, _val} -> y end)
        |> Enum.min_max()

      {coord, (x - min_x) * (max_x - x) * (y - min_y) * (max_y - y)}
    end)
  end

  def task1(input) do
    input
    |> visible_trees
    |> Enum.count()
  end

  def task2(input) do
    input
    |> scenic_trees()
    |> Enum.sort_by(fn {_coord, value} -> value end, :desc)
    |> List.first()
    |> elem(1)
  end
end

input = AOC2022.Day8.import("input_day08.txt")

input
|> AOC2022.Day8.task1()
|> IO.puts()

input
|> AOC2022.Day8.task2()
|> IO.puts()
