defmodule Tagcursion do
  @moduledoc """
  Tagcursion is the gateway for aggregating  structs
  """

  @doc """
  Read a list of entities into memory from `filepath`
  """
  def read_json(filepath) do
    filepath
    |> File.read!
    |> Poison.decode!(as: [%{}])
    |> Enum.into(%{}, &({&1["id"], &1}))
  end
  
  def reduce_tags(tag_store, tag, acc \\ [])

  @doc """
  Collect a list of tags from a tag's related tag_ids
  """
  def reduce_tags(tag_store, tag, acc) when is_map(tag),
    do: reduce_tags(tag_store, Map.get(tag, "tags", []), acc)

  @doc """
  Collect a list of tags from a list of `tag_ids`
  """
  def reduce_tags(tag_store, tag_ids, acc) when is_list(tag_ids) do
    tag_ids
    |> Enum.reverse
    |> Enum.reduce(acc, &(reduce_tags(tag_store, &1, &2)))
  end

  @doc """
  Collect a list of tags referenced by a `tag_id`
  """
  def reduce_tags(tag_store, tag_id, acc) when is_bitstring(tag_id) do
    tag = Map.fetch!(tag_store, tag_id)
    [tag | reduce_tags(tag_store, tag, acc)]
  end
end
