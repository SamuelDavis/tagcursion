defmodule Tagcursion.JsonStore do
  @moduledoc """
  Tagcursion.JsonStore is the gateway reading/writing file maps to .json files.
  """

  def read(path \\ "data") do
    cond do
      File.dir?(path) -> path
        |> File.ls!
        |> Enum.flat_map(&(read(path <> "/" <> &1)))
      Regex.match?(~r/\.json$/, path) -> path
        |> File.read!
        |> Poison.decode!(as: [%{}])
      true -> %{}
    end
  end

  def to_map(tag_list), do: Enum.into(tag_list, %{}, &({&1["id"], &1}))

  def compress(tag_map) do
    tag_map
    |> Enum.reduce(%{}, fn ({id, tag}, acc) ->
      parts = String.split(id, ".")
      parent = Enum.at(parts, -2, "tags")
      path = Enum.drop(parts, -2) |> Enum.join(".")
      namespace = Enum.drop(parts, -1) |> Enum.join(".")
      compressed_tags = Map.get(acc, namespace, {"_", "_", []}) |> elem(2)
      Map.put(acc, namespace, {path, parent, compressed_tags ++ [tag]})
    end)
  end

  def write(data, prefix \\ ".")

  def write({path, file, tags}, prefix) do
    path = String.replace(path, ".", "/")
    file = file <> ".json"

    [prefix, path]
    |> Enum.join("/")
    |> File.mkdir_p!

    [prefix, path, file]
    |> Enum.join("/")
    |> File.write!(tags |> Poison.encode!)
  end

  def write(tuples, prefix) when is_map(tuples),
    do: Map.values(tuples) |> write(prefix)

  def write(tuples, prefix) when is_list(tuples),
    do: Enum.map(tuples, &(write(&1, prefix)))
end
