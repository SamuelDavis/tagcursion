defmodule Tagcursion do
  @moduledoc """
  Tagcursion is the gateway for aggregating Tagcursion.Tag structs
  """

  @doc """
  Read a list of entities into memory from `filepath`
  """
  def read_json(filepath) do
    filepath
    |> File.read!
    |> Poison.decode!(as: [%Tagcursion.Tag{}])
    |> Enum.into(%{}, &({&1.id, &1}))
  end
  
  def reduce_tags(tag_store, tag, acc \\ [])

  @doc """
  Generate a list of `Tagcursion.Tag`s from a Tagcursion.Tag
  """
  def reduce_tags(tag_store, %Tagcursion.Tag{tags: tag_ids}, acc) do
    reduce_tags(tag_store, tag_ids, acc)
  end

  @doc """
  Collect a list of `Tagcursion.Tag`s from a list of `tag_ids`
  """
  def reduce_tags(tag_store, tag_ids, acc) when is_list(tag_ids) do
    tag_ids
    |> Enum.reverse
    |> Enum.reduce(acc, &(reduce_tags(tag_store, &1, &2)))
  end

  @doc """
  Collect a list of `Tagcursion.Tag` by `tag_id`
  """
  def reduce_tags(tag_store, tag_id, acc) when is_bitstring(tag_id) do
    tag = Map.fetch!(tag_store, tag_id)
    [tag | reduce_tags(tag_store, tag, acc)]
  end

  @doc """
  Collect a list of properties from all the reduced_tags of `tag` and `tag` itself
  """
  def reduce_prop(tag_store, tag, prop) do
    [tag | reduce_tags(tag_store, tag)]
    |> Enum.map(fn tag -> {tag.id, Map.get(tag.props, prop)} end)
  end
end
