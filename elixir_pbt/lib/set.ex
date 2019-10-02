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

  def put(%Set{} = set, element) do
    put_in(set.map[element], @dummy_value)
  end

  def delete(%Set{} = set, element) do
    {_value, new_set} = pop_in(set.map[element])
    new_set
  end
end
