defmodule ElixirPbt.SetTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias ElixirPbt.Set

  test "new/0 function returns an empty %Set{}" do
    assert set = %Set{} = Set.new()
    assert Set.empty?(set) == true
  end

  property "A set can be initialized with a list of terms" do
    check all(terms <- list_of(term())) do
      set = Set.new(terms)

      assert is_set?(set)
      assert contains_all_terms?(set, terms)
      assert is_correct_size?(set, terms)
    end
  end

  defp contains_all_terms?(%Set{} = set, terms) when is_list(terms) do
    Enum.all?(terms, fn t -> Set.member?(set, t) end)
  end

  defp is_set?(set) do
    match?(%Set{}, set)
  end

  defp is_correct_size?(%Set{} = set, terms) when is_list(terms) do
    Set.size(set) == Enum.uniq(terms) |> length()
  end

  test "A set not containing any terms is empty" do
    set = Set.new([])
    assert Set.empty?(set)
  end

  test "A set containing terms is not empty" do
    set = Set.new([1, 2, 3])
    refute Set.empty?(set)
  end

  # Not a great property test, see next test for better example
  @tag :skip
  property "A Set initialized with a non empty list of terms is not empty" do
    check all(
            list <-
              term()
              |> list_of()
              |> nonempty()
          ) do
      set = Set.new(list)
      assert Set.empty?(set) == false
    end
  end

  property "A set containing zero terms is empty" do
    check all(terms <- list_of(term())) do
      set = Set.new(terms)

      case length(terms) do
        0 -> assert Set.empty?(set)
        _ -> refute Set.empty?(set)
      end
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
        Enum.reduce(1..times_to_put, original_set, fn _index, acc ->
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
        Enum.reduce(1..times_to_delete, original_set, fn _index, acc ->
          Set.delete(acc, term_to_delete)
        end)

      assert new_set == original_set
    end
  end

  # Good example. Had to split a list of unique terms since two random lists
  # could share common terms in addition to the "common_terms" list
  property "The intersection of two Sets is a Set of the common terms between the two Sets" do
    check all(
            uniq_terms <- uniq_list_of(term(), min_length: 2),
            common_terms <-
              term()
              |> list_of()
              |> nonempty()
          ) do
      in_half =
        uniq_terms
        |> length()
        |> div(2)

      {front, back} = Enum.split(uniq_terms, in_half)
      set1 = Set.new(front ++ common_terms)
      set2 = Set.new(back ++ common_terms)
      assert Set.intersection(set1, set2) == Set.new(common_terms)
    end
  end

  property "The intersection of a Set with an empty Set is the empty Set" do
    check all(terms <- term() |> list_of()) do
      set = Set.new(terms)
      empty_set = Set.new()
      assert Set.intersection(set, empty_set) == empty_set
    end
  end

  property "The intersection of a Set with itself is the original Set" do
    check all(terms <- term() |> list_of()) do
      set = Set.new(terms)
      assert Set.intersection(set, set) == set
    end
  end

  property "The intersection of two Sets is commutative" do
    check all(
            terms1 <- term() |> list_of(),
            terms2 <- term() |> list_of()
          ) do
      set1 = Set.new(terms1)
      set2 = Set.new(terms2)

      assert Set.intersection(set1, set2) == Set.intersection(set2, set1)
    end
  end

  property "The intersection of a number of Sets is associative" do
    check all(
            number_of_sets <- integer(3..10),
            uniq_terms <- term() |> uniq_list_of(min_length: number_of_sets),
            common_terms <- term() |> list_of() |> nonempty()
          ) do
      # Breaks terms into the provided number of lists, last list may
      # contain fewer than the others
      chunk_size =
        uniq_terms
        |> length()
        |> div(number_of_sets)
        |> ceil()

      [first_set | rest] =
        Enum.chunk_every(uniq_terms, chunk_size)
        |> Enum.map(&Set.new(&1 ++ common_terms))

      intersection_result =
        Enum.reduce(rest, first_set, fn set, result ->
          Set.intersection(set, result)
        end)

      assert intersection_result == Set.new(common_terms)
    end
  end

  # Used as an example for shrinking. The put many function has a bug in it
  # where it won't put any numbers in the set that are divisible by 4.
  @tag :skip
  property "A set should be able to have multiple terms put at one time" do
    check all(terms <- list_of(term())) do
      set =
        Set.new()
        |> Set.put_many(terms)

      assert Enum.all?(terms, fn t -> Set.member?(set, t) end)
    end
  end
end
