defmodule TagcursionTest do
  use ExUnit.Case
  doctest Tagcursion

  test "it collects a list of tags by id" do
    tag_map = %{
      "tags.foo" => %{ "id" => "tags.foo" },
      "tags.bar" => %{ "id" => "tags.bar" }
    }
    assert Tagcursion.get_tags(tag_map, "tags.foo") == [tag_map["tags.foo"]]
  end

  test "it collects a list of tags by namespace" do
    tag_map = %{
      "tags.foo.a" => %{ "id" => "tags.foo.a" },
      "tags.foo.b" => %{ "id" => "tags.foo.b" },
      "tags.bar.a" => %{ "id" => "tags.bar.a" },
      "tags.bar.b" => %{ "id" => "tags.bar.b" }
    }
    assert Tagcursion.get_tags(tag_map, "tags.foo.*") == [
      tag_map["tags.foo.a"],
      tag_map["tags.foo.b"]
    ]
  end

  test "it formats tag ids into tags" do
    tag_map = %{
      "tags.foo" => %{ "id" => "tags.foo" },
      "tags.bar" => %{ "id" => "tags.bar" }
    }
    assert Tagcursion.format(tag_map, ["tags.foo"]) == [tag_map["tags.foo"]]
  end

  test "format flattens lists" do
    assert Tagcursion.format(%{}, [["foo"]]) == ["foo"]
  end

  test "format flattens deeply-nested lists" do
    assert Tagcursion.format(%{}, [[["foo"]]]) == ["foo"]
  end

  test "format converts non-lists into lists" do
    assert Tagcursion.format(%{}, "foo") == ["foo"]
  end

  test "format converts non-lists into flat lists" do
    assert Tagcursion.format(%{}, ["foo", ["bar"]]) == ["foo", "bar"]
  end

  test "format mixes tags and non-lists into flat lists" do
    tag_map = %{
      "tags.foo" => %{ "id" => "tags.foo" },
      "tags.bar" => %{ "id" => "tags.bar" }
    }
    assert Tagcursion.format(tag_map, ["tags.foo", "bar", ["qux"]]) == [
      tag_map["tags.foo"],
      "bar",
      "qux"
    ]
  end
end
