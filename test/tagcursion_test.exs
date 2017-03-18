defmodule TagcursionTest do
  use ExUnit.Case
  doctest Tagcursion

  defp assert_list(given, expected) do
    assert Enum.sort(given) == Enum.sort(expected)
  end

  test "it collects a list of tags by id" do
    tag_map = %{
      "tags.foo" => %{ "id" => "tags.foo" },
      "tags.bar" => %{ "id" => "tags.bar" }
    }
    Tagcursion.get_tags(tag_map, "tags.foo")
    |> assert_list([tag_map["tags.foo"]])
  end

  test "it collects a list of tags by namespace" do
    tag_map = %{
      "tags.foo.a" => %{ "id" => "tags.foo.a" },
      "tags.foo.b" => %{ "id" => "tags.foo.b" },
      "tags.bar.a" => %{ "id" => "tags.bar.a" },
      "tags.bar.b" => %{ "id" => "tags.bar.b" }
    }
    Tagcursion.get_tags(tag_map, "tags.foo.*")
    |> assert_list([
      tag_map["tags.foo.a"],
      tag_map["tags.foo.b"]
    ])
  end

  test "it formats tag ids into tags" do
    tag_map = %{
      "tags.foo" => %{ "id" => "tags.foo" },
      "tags.bar" => %{ "id" => "tags.bar" }
    }
    Tagcursion.format(tag_map, ["tags.foo"])
    |> assert_list([tag_map["tags.foo"]])
  end

  test "format flattens lists" do
    Tagcursion.format(%{}, [["foo"]])
    |> assert_list(["foo"])
  end

  test "format flattens deeply-nested lists" do
    Tagcursion.format(%{}, [[["foo"]]])
    |> assert_list(["foo"])
  end

  test "format converts non-lists into lists" do
    Tagcursion.format(%{}, "foo")
    |> assert_list(["foo"])
  end

  test "format converts non-lists into flat lists" do
    Tagcursion.format(%{}, ["foo", ["bar"]])
    |> assert_list(["foo", "bar"])
  end

  test "format mixes tags and non-lists into flat lists" do
    tag_map = %{
      "tags.foo" => %{ "id" => "tags.foo" },
      "tags.bar" => %{ "id" => "tags.bar" }
    }
    Tagcursion.format(tag_map, ["tags.foo", "bar", ["qux"]])
    |> assert_list([
      tag_map["tags.foo"],
      "bar",
      "qux"
    ])
  end

  test "search returns a list of keys in the immediate context" do
    tag_map = %{
      "tags.foo.a" => %{ "id" => "tags.foo.a" },
      "tags.bar.a" => %{ "id" => "tags.bar.a" },
      "tags.qux" => %{ "id" => "tags.qux" }
    }

    Tagcursion.search(tag_map, "tags.*")
    |> assert_list([
      "tags.qux"
    ])
  end

  test "full-search returns a list of keys in the immediate context" do
    tag_map = %{
      "tags.foo.a" => %{ "id" => "tags.foo.a" },
      "tags.bar.a" => %{ "id" => "tags.bar.a" },
      "tags.qux" => %{ "id" => "tags.qux" }
    }

    Tagcursion.search(tag_map, "tags.**")
    |> assert_list([
      "tags.foo.a",
      "tags.bar.a",
      "tags.qux"
    ])
  end
end
