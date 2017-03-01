defmodule Tagcursion.Cli do
  def build_tag do
    id = String.trim(IO.gets("Id: "))
    tags = String.split(IO.gets("Associated Tags: "), ",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    props = read_props()

    Tagcursion.hydrate({id, props, tags})
  end

  defp read_props(props \\ %{}) do
    case String.split(IO.gets("Prop: "), "=") do
      ["done\n"] -> props
      [prop, value] -> props
      |> Map.put(String.trim(prop), String.trim(value))
      |> read_props
      _ -> read_props(props)
    end
  end
end
