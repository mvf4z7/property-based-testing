defmodule ElixirPbt.SetTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias ElixirPbt.Set

  test "new/0 function returns an empty %Set{}" do
    assert set = %Set{} = Set.new()
    assert Set.empty?(set) == true
  end

  property "A Set initialized with a non empty list of terms is not empty" do
    check all(
            list <-
              term()
              |> list_of()
              |> nonempty()
          ) do
      set = Set.new(list)
      # IO.inspect(list)
      # Shows that functions were passed in. What if we didn't think of this edge case?
      # Other languages, there are other considerations (Java and integer overflow from addition)
      assert Set.empty?(set) == false
    end
  end

  # Forgot case where two terms with teh same value Set.new([1, 1]). Size equal 1
  # Original property: A Set initialized with a non empty list of terms has the same size as the number of terms
  # Next try: A Set initialized with list of terms has a size that is less than or equal to number of terms in the list
  #   Didnt like this one because [1, 1, 1, 2], size should be 2, but size 3 would assert true
  property "A Set initialized with a list of terms should have a size equal to the number of unique values in the list" do
    check all(list <- uniq_list_of(term())) do
      duplicated_list = list ++ list
      set = Set.new(duplicated_list)
      assert Set.size(set) == length(list)
    end
  end

  property "A Set initialized with a list of terms should include each term as a member" do
    check all(list <- list_of(term())) do
      set = Set.new(list)

      Enum.each(list, fn elem ->
        assert Set.member?(set, elem) == true
      end)
    end
  end

  property "A Set initialized with a list of values does not contain any members that were not in the initialization list" do
    check all(list <- term() |> uniq_list_of(min_length: 2)) do
      in_half =
        list
        |> length()
        |> div(2)

      {front, back} = Enum.split(list, in_half)
      set = Set.new(front)

      Enum.each(back, fn elem ->
        assert Set.member?(set, elem) == false
      end)
    end
  end

  property "A Set that has a term added to it should include that term as a member" do
    check all(
            list <-
              term()
              |> uniq_list_of()
              |> nonempty()
          ) do
      [first | rest] = list

      set =
        Set.new(rest)
        |> Set.put(first)

      assert Set.member?(set, first) == true
    end
  end

  property "A Set's size should increment when a new term is added" do
    check all(
            terms <-
              term()
              |> uniq_list_of()
              |> nonempty()
          ) do
      [first | rest] = terms
      set = Set.new(rest)
      original_size = Set.size(set)
      new_set = Set.put(set, first)

      assert Set.size(new_set) == original_size + 1
    end
  end

  # This used to check that the size was the same, now full equality check
  # This feels more property like, more substantial of a claim
  property "A Set should not change when putting the same term in it multiple times" do
    check all(
            terms <-
              term()
              |> uniq_list_of()
              |> nonempty(),
            term_to_put <- member_of(terms),
            times_to_put <- integer(1..10)
          ) do
      original_set = Set.new(terms)

      new_set =
        Enum.reduce(1..times_to_put, original_set, fn _, acc ->
          Set.put(acc, term_to_put)
        end)

      assert new_set == original_set
    end
  end

  property "A set that has a term deleted from it should no longer have that term as a member" do
    check all(
            terms <-
              term()
              |> list_of()
              |> nonempty(),
            term_to_remove <- member_of(terms)
          ) do
      set =
        terms
        |> Set.new()
        |> Set.delete(term_to_remove)

      assert Set.member?(set, term_to_remove) == false
    end
  end

  property "A Set's size should decrement after deleting an element from it" do
    check all(
            terms <-
              term()
              |> list_of()
              |> nonempty(),
            term_to_remove <- member_of(terms)
          ) do
      original_set = Set.new(terms)
      new_set = Set.delete(original_set, term_to_remove)

      assert Set.size(new_set) == Set.size(original_set) - 1
    end
  end

  property "A Set should not change when deleting the same term from it multiple times" do
    check all(
            terms <-
              term()
              |> uniq_list_of()
              |> nonempty(),
            term_to_delete <- member_of(terms),
            times_to_delete <- integer(1..10)
          ) do
      original_set =
        terms
        |> Set.new()
        |> Set.delete(term_to_delete)

      new_set =
        Enum.reduce(1..times_to_delete, original_set, fn _, acc ->
          Set.delete(acc, term_to_delete)
        end)

      assert new_set == original_set
    end
  end
end
