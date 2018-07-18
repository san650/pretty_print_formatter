defmodule PrettyPrintFormatter do
  @ecto PrettyPrintFormatter.Ecto
  #@phoenix PrettyPrintFormatter.Phoenix
  @default PrettyPrintFormatter.Default

  # Test ecto
  def write(level, ["QUERY", _, _, _, _, _, _, _, _, _, _] = message, timestamp, metadata) do
    formatted = @ecto.run(message)

    pretty(level, formatted, timestamp, metadata)
  end

  def write(level, message, timestamp, metadata) do
    formatted = @default.run(message)

    pretty(level, formatted, timestamp, metadata)
  end

  defp pretty(level, message, timestamp, [request_id: request_id]) do
    id = [:yellow, :faint, "[", request_id |> String.slice(0..5), "] ", :reset]

    flush(level, [id | message], timestamp, [])
  end

  defp pretty(level, message, timestamp, _) do
    id = [:yellow, :faint, "[------] ", :reset]

    flush(level, [id | message], timestamp, [])
  end

  defp flush(level, message, _timestamp, _metadata) do
    try do
      [message, "\n"] |> IO.ANSI.format
    rescue
      error -> [inspect(error), message]
    end
  end
end
