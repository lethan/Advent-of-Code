defmodule AoC.Zipper do
  defstruct(front: [], back: [])

  def new() do
    %__MODULE__{}
  end

  def peek(zipper, default \\ nil)
  def peek(%__MODULE__{front: [value | _]}, _default), do: value
  def peek(%__MODULE__{front: [], back: []}, default), do: default

  def peek(%__MODULE__{front: [], back: back}, default) do
    peek(%__MODULE__{front: Enum.reverse(back), back: []}, default)
  end

  def enqueue(%__MODULE__{front: [], back: []}, value) do
    %__MODULE__{front: [value], back: []}
  end

  def enqueue(%__MODULE__{front: front, back: back}, value) do
    %__MODULE__{front: front, back: [value | back]}
  end

  def dequeue(zipper, default \\ nil)

  def dequeue(%__MODULE__{front: [], back: []} = zipper, default) do
    {default, zipper}
  end

  def dequeue(%__MODULE__{front: [], back: back}, default) do
    dequeue(%__MODULE__{front: Enum.reverse(back), back: []}, default)
  end

  def dequeue(%__MODULE__{front: [value], back: back}, _default) do
    {value, %__MODULE__{front: Enum.reverse(back), back: []}}
  end

  def dequeue(%__MODULE__{front: [value | rest], back: back}, _default) do
    {value, %__MODULE__{front: rest, back: back}}
  end

  def empty?(%__MODULE__{front: [], back: []}), do: true
  def empty?(%__MODULE__{}), do: false

  def size(%__MODULE__{front: front, back: back}) do
    length(front) + length(back)
  end
end

defimpl Enumerable, for: AoC.Zipper do
  def count(zipper = %AoC.Zipper{}), do: {:ok, AoC.Zipper.size(zipper)}

  def member?(%AoC.Zipper{front: [], back: []}, _value), do: {:ok, false}
  def member?(_zipper, _value), do: {:error, __MODULE__}

  def slice(%AoC.Zipper{front: [], back: []}), do: {:ok, 0, fn _, _, _ -> AoC.Zipper.new() end}
  def slice(_zipper), do: {:error, __MODULE__}

  def reduce(_zipper, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(zipper, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(zipper, &1, fun)}
  def reduce(%AoC.Zipper{front: [], back: []}, {:cont, acc}, _fun), do: {:done, acc}

  def reduce(zipper, {:cont, acc}, fun) do
    {value, rest} = AoC.Zipper.dequeue(zipper)
    reduce(rest, fun.(value, acc), fun)
  end
end

defimpl Collectable, for: AoC.Zipper do
  def into(zipper) do
    {zipper, &collector_fun/2}
  end

  defp collector_fun(zipper, {:cont, elem}), do: AoC.Zipper.enqueue(zipper, elem)
  defp collector_fun(zipper, :done), do: zipper
  defp collector_fun(_zipper, :halt), do: :ok
end
