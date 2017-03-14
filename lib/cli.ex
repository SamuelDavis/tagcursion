defmodule Tagcursion.Cli do
  @moduledoc """
  Tagcursion.Cli is the gateway for generating tags and tag_maps.
  """

  def build_tag(tag_map \\ %{}) do
    id = read_prop("id")

    default = Map.get(tag_map, id, %{})
    default_effects = Map.get(default, "effects", []) |> Enum.join(";")
    default_tags = Map.get(default, "tags", []) |> Enum.join(";")

    if default !== %{} do
      IO.puts "Default:"
      IO.inspect default
    end

    %{
      "id" => id,
      "name" => read_prop("name", default["name"]),
      "desc" => read_prop("desc", default["desc"]),
      "effects" => read_prop("effects", default_effects) |> String.split(";"),
      "tags" => read_prop("tags", default_tags) |> String.split(";")
    }
    |> Enum.into(read_props())
    |> Enum.into(default)
    |> Enum.reject(fn ({_key, val}) -> cond do
      is_list(val) -> Enum.reject(val, &(&1 == "")) == []
      is_bitstring(val) -> val == ""
      true -> false
    end end)
    |> Enum.into(%{})
  end

  defp read_prop(prompt \\ "Prop", default \\ "")
  defp read_prop(prompt, nil), do: read_prop(prompt, "")
  defp read_prop(prompt, default) do
    case IO.gets("#{prompt} [#{default}]: ") |> String.trim do
      "" -> default
      input -> input
    end
  end

  defp read_props(props \\ %{}) do
    case read_prop() |> String.split("=") do
      [prop, value] -> if (String.contains?(value, ";")),
        do: Map.put(props, prop, String.split(value, ";")) |> read_props(),
        else: Map.put(props, prop, value) |> read_props()
      _ -> props
    end
  end

  def build_tags(tag_map \\ %{}) do
    tag = build_tag(tag_map)
    IO.inspect(tag)
    tag_map = Map.put(tag_map, tag["id"], tag)
    case IO.gets("Stop? ") do
      "y\n" -> tag_map
      _ -> build_tags(tag_map)
    end
  end
end
