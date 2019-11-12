defmodule ElixirPbt.ExamplesTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias ElixirPbt.Buggy

  @tag :split
  property "String.split - Joining a split string should result in the original string" do
    check all(
            original_str <- string(:ascii, min_length: 20),
            delimeter <-
              original_str
              |> String.to_charlist()
              |> StreamData.string(min_length: 1)
            # delimeter <- string(:ascii, min_length: 1)
            # delimeter <- string(:ascii)
          ) do
      result =
        original_str
        # |> String.split(delimeter)
        |> Buggy.split(delimeter)
        |> Enum.join(delimeter)

      assert result == original_str
    end
  end

  test "Enum.sort sorts a list" do
    result = Enum.sort([2, 1, 3])
    assert result == [1, 2, 3]

    result = Enum.sort([1, 2, 3])
    assert result == [1, 2, 3]

    result = Enum.sort([20, 99, -20])
    assert result == [-20, 20, 99]
  end

  @tag :only

  property "Enum.sort returns a sorted list" do
    check all(terms <- list_of(term())) do
      result = Enum.sort(terms)

      assert is_list(result)
      assert same_elements?(terms, result)
      assert ordered?(result)
    end
  end

  defp same_elements?(list1, list2)
       when is_list(list1) and
              is_list(list2) do
    length(list1) == length(list2) && list1 -- list2 == []
  end

  defp ordered?([]), do: true
  defp ordered?([_head | []]), do: true

  defp ordered?([first | [second | rest]]) do
    first <= second && ordered?(rest)
  end

  property "The length of a list should remain the same after sorting" do
    check all(terms <- list_of(term())) do
      sorted = Enum.sort(terms)
      assert length(sorted) == length(terms)
    end
  end

  property "Calling reverse on a list twice should result in the original list" do
    check all(list <- list_of(integer())) do
      result =
        list
        |> Enum.reverse()
        |> Enum.reverse()

      assert result == list
    end
  end

  property "Sorting a list should be idempotent" do
    check all(
            list <- list_of(term()),
            times <- integer(2..10)
          ) do
      initial_value = Enum.sort(list)

      result =
        Enum.reduce(1..times, initial_value, fn _count, acc ->
          Enum.sort(acc)
        end)

      assert result == initial_value
    end
  end
end
