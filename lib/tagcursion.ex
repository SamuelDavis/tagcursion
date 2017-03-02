defmodule Tagcursion do
  alias :ets, as: Ets
  @table :tags

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
  def save(tag) do
    Ets.insert(@table, dehydrate(tag))
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
    |> Map.values
    |> Enum.map(&(Map.fetch!(&1, "id")))

    {id, props, tags}
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
