defmodule TagcursionTest do
  use ExUnit.Case
  doctest Tagcursion

  setup do
    [tag_store: Tagcursion.read_json("data/example.json")]
  end

  test "it loads tags from a JSON list", %{tag_store: tag_store} do
    assert tag_store == %{
      "Bar" => %Tagcursion.Tag{id: "Bar", props: %{"ex" => 2}, tags: []},
      "Fiz" => %Tagcursion.Tag{id: "Fiz", props: %{"nested_prop" => %{"nested_a" => "fiz_nested_prop_a"}}, tags: ["Foo", "Bar"]},
      "Foo" => %Tagcursion.Tag{id: "Foo", props: %{"ex" => 1, "nested_prop" => %{"nested_a" => "foo_nested_prop_a", "nested_b" => "foo_nested_prop_b"}}, tags: ["Bar"]}
    }
  end

  test "it reduces a specific tag by id", %{tag_store: tag_store} do
    assert Tagcursion.reduce_tags(tag_store, "Foo") == [
      tag_store["Foo"],
      tag_store["Bar"]
    ]
  end

  test "it raises if reducing a tag which doesn't exist", %{tag_store: tag_store} do
    assert_raise KeyError, ~r/^key "Foobar" not found/, fn ->
      Tagcursion.reduce_tags(tag_store, "Foobar")
    end
  end

  test "it reduces a list of tag ids", %{tag_store: tag_store} do
    assert Tagcursion.reduce_tags(tag_store, ["Foo"]) == [
      tag_store["Foo"],
      tag_store["Bar"]
    ]
  end

  test "it reduces tags from maps which have a list of `tags`", %{tag_store: tag_store} do
    assert Tagcursion.reduce_tags(tag_store, tag_store["Fiz"]) == [
      tag_store["Foo"],
      tag_store["Bar"],
      tag_store["Bar"]
    ]
  end

  test "it reduces a given property on a tag", %{tag_store: tag_store} do
    assert Tagcursion.reduce_prop(tag_store, tag_store["Fiz"], "ex") == [
      {"Fiz", nil},
      {"Foo", 1},
      {"Bar", 2},
      {"Bar", 2}
    ]
  end

  test "it reduces nested properites on a tag", %{tag_store: tag_store} do
    given = Tagcursion.reduce_prop(tag_store, tag_store["Fiz"], ["nested_prop", "nested_a"])
    assert given == [
      {"Fiz", "fiz_nested_prop_a"},
      {"Foo", "foo_nested_prop_a"},
      {"Bar", nil},
      {"Bar", nil}
    ]
  end
end
