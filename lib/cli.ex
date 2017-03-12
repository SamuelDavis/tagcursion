defmodule Tagcursion.Cli do
  def build_tag() do
    %{
      "id" => read_prop("Id"),
      "name" => read_prop("Name"),
      "desc" => read_prop("Description"),
      "effects" => read_prop("Effects") |> String.split(";"),
      "tags" => read_prop("Tags") |> String.split(";")
    }
    |> Enum.into(read_props())
  end

  defp read_prop(prompt \\ "Prop"), do: String.trim(IO.gets(prompt <> ": "))

  defp read_props(props \\ %{}) do
    case read_prop() |> String.split("=") do
      [prop, value] -> if (String.contains?(value, ";")),
        do: Map.put(props, prop, String.split(value, ";")) |> read_props(),
        else: Map.put(props, prop, value) |> read_props()
      _ -> props
    end
  end

  def build_tags(tag_map \\ %{}) do
    tag = build_tag()
    tag_map = Map.put(tag_map, tag["id"], tag)
    case IO.gets("Stop? ") do
      "y\n" -> tag_map
      _ -> build_tags(tag_map)
    end
  end
end
