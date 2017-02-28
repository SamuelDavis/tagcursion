defmodule Tagcursion do
  @moduledoc """
  Tagcursion is the gateway for aggregating  structs
  """

  @doc """
  Collect a list of tags into a map from the `data_dir` directory path
  """
  def read_json_dir(data_dir \\ "data/") do
    data_dir
    |> File.ls!
    |> Stream.map(fn filename -> path = data_dir <> filename
      cond do
        File.dir?(path) -> read_json_dir(path <> "/")
        Regex.match?(~r/\.json$/, path) -> File.read!(path) |> Poison.decode!(as: [%{}])
        true -> []
      end
    end)
    |> Enum.concat
  end

  @doc """
  Read a `tag_list` into a map, keyed by "id"
  """
  def tag_list_to_map(tag_list) do
    Enum.into(tag_list, %{}, &({&1["id"], &1}))
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

  def filter_tags(tag_store, regex) do
    Enum.filter(tag_store, fn({id, _tag}) -> Regex.match?(regex, id) end) |> Enum.into(%{})
  end
end
