defmodule Tagcursion do
  @moduledoc """
  Tagcursion is a gateway for aggregating maps.
  """

  def reduce_prop(_tag_map, _prop, []), do: []
  def reduce_prop(_tag_map, _prop, source) when is_nil(source), do: []
  def reduce_prop(tag_map, prop, source) when is_list(source),
    do: Enum.flat_map(source, &(reduce_prop(tag_map, prop, &1)))
  def reduce_prop(tag_map, prop, source) when is_bitstring(source),
    do: reduce_prop(tag_map, prop, get_tags(tag_map, source))
  def reduce_prop(tag_map, prop, source) do
    [{source["id"], source[prop]}] ++ reduce_prop(tag_map, prop, source["tags"])
    |> Enum.map(fn {id, val} -> {id, format(tag_map, val)} end)
    |> Enum.reject(fn {_id, [val|_rest]} -> is_nil(val) end)
  end

  def format(tag_map, item) when is_list(item),
    do: Enum.flat_map(item, &(format(tag_map, &1)))
  def format(tag_map, item) when is_bitstring(item) do
    cond do
      String.starts_with?(item, "tags.") -> get_tags(tag_map, item)
      true -> [template(tag_map, item)]
    end
  end
  def format(_tag_map, item), do: [item]

  def template(_tag_map, text), do: text

  def get_tags(tag_map, id) when is_bitstring(id) do
    tag_map
      |> search(id)
      |> Enum.map(&(tag_map[&1]))
  end

  def search(tag_map, id) do
    regex = id
    |> String.replace(".", "\.")
    |> String.replace("**", "[a-z_\.]+$")
    |> String.replace("*", "[a-z_]+$")
    |> Regex.compile!

    tag_map
    |> Map.keys()
    |> Enum.filter(&(Regex.match?(regex, &1)))
  end
end
