defmodule Tagcursion do
  alias :ets, as: Ets
  @table :tags

  @doc """
  ## Examples
    iex> Tagcursion.read_json("data/foobar.json")
    [{"Foo", %{}, ["Bar"]}, {"Bar", %{"prop1" => "a"}, []}]
  """
  def read_json(path) do
    cond do
      File.dir?(path) -> File.ls!(path) |> Enum.flat_map(&(read_json(path <> "/" <> &1)))
      Regex.match?(~r/\.json$/, path) -> File.read!(path) |> Poison.decode!(as: [%{}]) |> Enum.map(&dehydrate/1)
      true -> [] 
    end
  end

  @doc """
  Convert a list of ids to a list of json-writable data blobs keyed by namespace
  Examples don't work because doc can't parse json-encoded strings super well.
  The returned structure is:
  %{
    "tags.some.namespace" => "json_encoded_list_of_tags",
    "tags.some.other.namespace" => "another_json_encoded_list_of_tags",
    ...
  }
  """
  def to_json(ids) do
    ids
    |> Enum.map(&(Regex.run(~r/^([a-z0-9\.]+)\.([a-z0-9]+)$/, "tags." <> &1)))
    |> Enum.reduce(%{}, fn ([id, path, _name], acc) ->
      tag = read(String.replace(id, ~r/^tags\./, ""))
      stored_tags = Map.get(acc, path, [])
      Map.put(acc, path, stored_tags ++ [dehydrate_relations(tag)])
    end)
    |> Enum.map(fn {namespace, tags} -> {namespace, Poison.encode!(tags)} end)
    |> Enum.into(%{})
  end

  @doc """
  Initialize the Erlang Term Storage table to hold tags.
  ## Examples
    iex> Tagcursion.init
    :tags
  """
  def init do
    Ets.new(@table, [:set, :protected, :named_table])
  end

  @doc """
  Create or update a tag
  ## Examples
    iex> Tagcursion.init
    iex> Tagcursion.save %{"id" => "foo"}
    :true
  """
  def save(tag) when is_map(tag), do: tag |> dehydrate |> save

  @doc """
  ## Examples
    iex> Tagcursion.init
    iex> Tagcursion.save {"foo", %{}, []}
    :true
  """
  def save(tag) when is_tuple(tag) do
    Ets.insert(@table, tag)
  end

  @doc """
  Fetch a (hydrated) tag by it's fully-qualified id
  ## Examples
    iex> Tagcursion.init
    iex> Tagcursion.save %{"id" => "foo"}
    iex> Tagcursion.read "foo"
    %{"id" => "foo", "tags" => %{}}
  """
  def read(id) do
    case Ets.lookup(@table, id) do
      [tag] -> hydrate(tag)
      _ -> nil
    end
  end

  @doc """
  Hydrate a tag to a map from its Ets-friendly struct
  ## Examples
    iex> Tagcursion.init
    iex> Tagcursion.save %{"id" => "foo"}
    iex> Tagcursion.hydrate {"bar", %{"name" => "Bar"}, ["foo"]}
    %{
      "id" => "bar",
      "name" => "Bar",
      "tags" => %{
        "foo" => %{"id" => "foo", "tags" => %{}}
      }
    }
  """
  def hydrate({id, props, tags}) do
    props
    |> Map.put("id", id)
    |> Map.put("tags", Enum.into(tags, %{}, &({&1, read(&1)})))
  end

  @doc """
  Dehydrate a tag from map to an Ets-friendly tuple
  ## Examples
    iex> Tagcursion.dehydrate %{"id" => "bar", "name" => "Bar", "tags" => %{"foo" => %{"id" => "foo", "tags" => %{}}}}
    {"bar", %{"name" => "Bar"}, ["foo"]}
  """
  def dehydrate(tag) do
    id = Map.fetch!(tag, "id")
    props = Map.drop(tag, ["id", "tags"])
    tags = Map.get(tag, "tags", %{})
    tags = cond do
      is_map(tags) -> Map.values(tags) |> Enum.map(&(Map.fetch!(&1, "id")))
      is_list(tags) -> tags
    end

    {id, props, tags}
  end

  @doc """
  Convert a tags' nested "tags" relation to a flat list of ids
  ## Examples
    iex> Tagcursion.dehydrate_relations %{"id" => "bar", "tags" => %{"foo" => %{"id" => "foo", "tags" => %{}}}}
    %{"id" => "bar", "tags" => ["foo"]}
  """

  def dehydrate_relations(tag) do
    ids = Map.get(tag, "tags", %{}) |> Map.keys
    Map.put(tag, "tags", ids)
  end

  @doc """
  Reduce a tag and its recursive relations to a list
  ## Examples
    iex> Tagcursion.flatten %{"id" => "qux", "tags" => %{"bar" => %{"id" => "bar", "tags" => %{"foo" => %{"id" => "foo"}}}}}
    [
      %{
        "id" => "qux",
        "tags" => %{
          "bar" => %{
            "id" => "bar",
            "tags" => %{"foo" => %{"id" => "foo"}}
          }
        }
      },
      %{
        "id" => "bar",
        "tags" => %{
          "foo" => %{"id" => "foo"}
        }
      },
      %{"id" => "foo"}
    ]
  """
  def flatten(tag) do
    tag
    |> Map.get("tags", %{})
    |> Map.values
    |> Enum.reduce([tag], &(&2 ++ flatten(&1)))
  end

  @doc """
  List the stored tag ids
  ## Examples
    iex> Tagcursion.init
    iex> Tagcursion.save %{"id" => "foo"}
    iex> Tagcursion.save %{"id" => "bar"}
    iex> Tagcursion.keys
    ["foo", "bar"]
  """
  def keys() do
    first = Ets.first(@table)
    keys(first, [first])
  end

  defp keys(:"$end_of_table", [:"$end_of_table"|acc]), do: acc

  defp keys(currentKey, acc) do
    next = Ets.next(@table, currentKey)
    keys(next, [next|acc])
  end
end
