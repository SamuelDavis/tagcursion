defmodule Tagcursion.Cli do
  def build_tag do
    id = String.trim(IO.gets("Id: "))
    name = String.trim(IO.gets("Name: "))
    description = String.trim(IO.gets("Description: "))
    tags = String.split(IO.gets("Associated Tags: "), ",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    props = read_props()
    props = Map.put(props, "description", description)
    props = Map.put(props, "name", name)

    Tagcursion.hydrate({id, props, tags})
  end

  defp read_props(props \\ %{}) do
    case String.split(IO.gets("Prop: "), "=") |> Enum.map(&String.trim/1) do
      [prop, value] -> cond do
        String.contains?(value, ";") -> Map.put(props, prop, String.split(value, ";")) |> read_props
        true -> Map.put(props, prop, value) |> read_props
      end
      _ -> props
    end
  end
end
