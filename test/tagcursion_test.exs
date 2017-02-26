defmodule TagcursionTest do
  use ExUnit.Case
  doctest Tagcursion

  setup do
    [tag_store: Tagcursion.read_json("data/example.json")]
  end

  test "it loads tags from a JSON list", %{tag_store: tag_store} do
    assert tag_store == %{
      "Bar" => %{"id" => "Bar"},
      "Fiz" => %{"id" => "Fiz", "tags" => ["Foo", "Bar"]},
      "Foo" => %{"id" => "Foo", "tags" => ["Bar"]}
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
end
