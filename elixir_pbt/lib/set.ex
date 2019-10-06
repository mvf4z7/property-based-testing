defmodule ElixirPbt.Set do
  alias ElixirPbt.Set

  defstruct map: %{}

  @dummy_value :dummy_value

  def new() do
    %Set{}
  end

  def new(values) when is_list(values) do
    map = Enum.into(values, %{}, fn v -> {v, @dummy_value} end)
    %Set{map: map}
  end

  def values(%Set{} = set) do
    Map.keys(set.map)
  end

  def empty?(%Set{} = set) do
    Map.equal?(set.map, %{})
  end

  def size(%Set{} = set) do
    map_size(set.map)
  end

  def member?(%Set{} = set, element) do
    case Map.fetch(set.map, element) do
      {:ok, @dummy_value} -> true
      :error -> false
    end
  end

  def put_many(%Set{} = set, elements) when is_list(elements) do
    Enum.reduce(elements, set, fn element, acc ->
      case is_integer(element) && rem(element, 4) == 0 do
        true ->
          IO.inspect(elements)
          acc

        false ->
          Set.put(acc, element)
      end
    end)
  end

  def put(%Set{} = set, element) do
    put_in(set.map[element], @dummy_value)
  end

  def delete(%Set{} = set, element) do
    {_value, new_set} = pop_in(set.map[element])
    new_set
  end

  def intersection(%Set{} = set1, %Set{} = set2) do
    {smaller, larger} =
      case Set.size(set1) < Set.size(set2) do
        true -> {set1, set2}
        false -> {set2, set1}
      end

    smaller
    |> values()
    |> Enum.reduce(Set.new(), fn smaller_value, acc ->
      case Set.member?(larger, smaller_value) do
        true -> Set.put(acc, smaller_value)
        false -> acc
      end
    end)
  end
end
