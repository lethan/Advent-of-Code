defmodule PriorityQueue do
  defstruct queue: nil

  def new() do
    %__MODULE__{queue: :gb_trees.empty()}
  end

  def insert(%__MODULE__{queue: queue}, priority, element) do
    new_value =
      case :gb_trees.lookup(priority, queue) do
        :none ->
          [element]

        {:value, list} ->
          [element | list]
      end

    new_queue = :gb_trees.enter(priority, new_value, queue)

    %__MODULE__{queue: new_queue}
  end

  def get(%__MODULE__{queue: queue}) do
    {priority, list, new_queue} = :gb_trees.take_smallest(queue)

    {element, new_queue} =
      case list do
        [element] ->
          {element, new_queue}

        [element | rest] ->
          new_queue = :gb_trees.enter(priority, rest, new_queue)
          {element, new_queue}
      end

    {priority, element, %__MODULE__{queue: new_queue}}
  end

  def empty?(%__MODULE__{queue: queue}) do
    :gb_trees.is_empty(queue)
  end
end
