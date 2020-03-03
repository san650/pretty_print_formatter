defmodule PrettyPrintFormatter do
  @moduledoc """
  Elixir logger formatter for pretty print log messages in the console.
  """
  @ecto PrettyPrintFormatter.Ecto
  @phoenix PrettyPrintFormatter.Phoenix
  @default PrettyPrintFormatter.Default

  @caret "┃"
  @alternate_caret "●"

  @ecto_default_opts [
    short_params_list: true
  ]

  # Test for ecto log message
  def write(level, ["QUERY" | _] = message, timestamp, metadata) do
    opts = Keyword.merge(@ecto_default_opts, get_opts(:ecto))

    formatted = @ecto.run(message, opts)

    pretty(level, formatted, timestamp, metadata)
  end

  # Test for phoenix log message
  def write(level, [verb | _] = message, timestamp, metadata) when verb in ["GET", "POST", "PUT", "DELETE", "OPTIONS"] do
    formatted = @phoenix.run(message)
    color =
      metadata
      |> Keyword.get(:request_id)
      |> to_color

    pretty(level, formatted, timestamp, metadata, ["\n", color, String.pad_trailing("┏", 2, "━"), :reset, "\n"])
  end

  # Test for phoenix log message
  # Newer version of phoenix
  def write(level, ["Received " | _] = message, timestamp, metadata) do
    formatted = @phoenix.run(message)
    color =
      metadata
      |> Keyword.get(:request_id)
      |> to_color

    pretty(level, formatted, timestamp, metadata, ["\n", color, String.pad_trailing("┏", 2, "━"), :reset, "\n"])
  end

  # Test for phoenix log message
  def write(level, ["Sent" | _] = message, timestamp, metadata) do
    formatted = @phoenix.run(message)
    color =
      metadata
      |> Keyword.get(:request_id)
      |> to_color

    pretty(level, [formatted, "\n", color, String.pad_trailing("┗", 2, "━"), :reset], timestamp, metadata)
  end

  # Test for phoenix log message
  # Newer version of phoenix
  def write(level, ["Sent " | _] = message, timestamp, metadata) do
    formatted = @phoenix.run(message)
    color =
      metadata
      |> Keyword.get(:request_id)
      |> to_color

    pretty(level, [formatted, "\n", color, String.pad_trailing("┗", 2, "━"), :reset], timestamp, metadata)
  end

  # Test for phoenix log message
  def write(level, ["Processing with " | _] = message, timestamp, metadata) do
    formatted = @phoenix.run(message)

    pretty(level, formatted, timestamp, metadata)
  end

  # Unknown log message
  def write(level, message, timestamp, metadata) do
    # IO.inspect(message, label: :message)
    # IO.inspect(metadata, label: :metadata)
    formatted = @default.run(message)

    pretty(level, formatted, timestamp, metadata)
  end

  defp pretty(level, message, timestamp, metadata, prefix \\ "")

  defp pretty(level, message, timestamp, [request_id: request_id], prefix) do
    id = [prefix, to_color(request_id), @caret, " ", :reset]

    flush(level, [id | message], timestamp, [])
  end

  defp pretty(level, message, timestamp, _, _prefix) do
    id = [:white, @alternate_caret, " ", :reset]

    flush(level, [id | message], timestamp, [])
  end

  defp flush(_level, message, _timestamp, _metadata) do
    try do
      [message, "\n"] |> IO.ANSI.format
    rescue
      error -> [inspect(error), message]
    end
  end

  @colors [
    :blue,
    :light_blue,
    :cyan,
    :light_cyan,
    :green,
    :light_green,
    :magenta,
    :light_magenta,
    :red,
    :light_red,
    :white,
    :light_white,
    :yellow,
    :light_yellow,
  ]

  defp to_color(nil), do: :white
  defp to_color(id) do
    index =
      id
      |> :erlang.crc32()
      |> rem(length(@colors))

    Enum.at(@colors, index)
  end

  defp get_opts(key) do
    Application.get_env(:pretty_print_formatter, key, [])
  end
end
