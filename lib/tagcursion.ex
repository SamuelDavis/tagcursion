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
    IO.inspect prop
    [source[prop]] ++ reduce_prop(tag_map, prop, source["tags"])
    |> Enum.flat_map(&(format(tag_map, &1)))
    |> Enum.reject(&is_nil/1)
  end

  def format(tag_map, item) when is_list(item),
    do: Enum.flat_map(item, &(format(tag_map, &1)))
  def format(tag_map, item) when is_bitstring(item) do
    if String.starts_with?(item, "tags."),
      do: get_tags(tag_map, item),
      else: [template(tag_map, item)]
  end
  def format(_tag_map, item), do: [item]

  def template(_tag_map, text), do: text

  def get_tags(tag_map, id) do
    regex = id
    |> String.replace(".", "\.")
    |> String.replace("*", "[a-z_]+")
    |> Regex.compile!

    tag_map
    |> Map.values()
    |> Enum.filter(&(Regex.match?(regex, &1["id"])))
  end
end
