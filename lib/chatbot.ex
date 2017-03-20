defmodule Tagcursion.Chatbot do
  use Slack
  @state %{
    "tags" => %{},
    "pcs" => %{}
  }

  # SERVER API
  def start(token), do: Slack.Bot.start_link(__MODULE__, @state, token)

  def handle_connect(_slack, state), do: {:ok, state}

  def handle_info({:put_state, prop, value}, _slack, state),
    do: {:ok, put_in(state, prop, value)}
  def handle_info(_, _, state), do: {:ok, state}

  # CHAT API
  def handle_event(message = %{type: "message", text: text}, slack, state) do
    words = String.split(text, " ")
    {target, words} = List.pop_at(words, 0)
    {cmd, words} = List.pop_at(words, 0)
    text = Enum.join(words, " ")

    if target == "<@#{slack.me.id}>",
      do: parse(cmd, text, message, slack, state),
      else: {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def parse("control", id, %{channel: channel, user: user}, slack, state) do
    respond("Controlling: " <> format(state["tags"][id]), channel, slack)
    {:ok, put_in(state, ["pcs", user], id)}
  end

  def parse(cmd, text, %{channel: channel, user: user}, slack, state) do
    %{"tags" => tags, "pcs" => pcs} = state
    id = pcs[user]
    tag = tags[id]

    case cmd do
      "me" -> me(tags, tag, text)
      "find" -> tags[text]
      "search" -> Tagcursion.search(tags, text)
      _ -> "Unknown command #{cmd}"
    end
    |> format
    |> respond(channel, slack)

    {:ok, state}
  end

  def me(_tags, nil, _prop), do: "Use the `control` command to bind your tag."
  def me(_tags, tag, ""), do: tag
  def me(tags, tag, prop), do: Tagcursion.reduce_prop(tags, prop, tag)

  def format(nil), do: "nothing"
  def format([]), do: "[]"
  def format(content) when is_list(content),
    do: Enum.map(content, &format/1) |> Enum.join("\n")
  def format(content) when is_map(content),
    do: Enum.map(content, fn {key, value} -> "#{key}: " <> format(value) end) |> format
  def format(content), do: content

  def respond(resp, channel, slack), do: send_message(resp, channel, slack)
end
