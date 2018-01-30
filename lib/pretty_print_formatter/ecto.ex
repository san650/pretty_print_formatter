defmodule PrettyPrintFormatter.Ecto do
  import PrettyPrintFormatter.Ecto.SqlTokenizer
  # https://github.com/elixir-ecto/ecto/blob/e243ff4597ad244ae5870dc1c9d3eb86fd91a507/lib/ecto/log_entry.ex#L77-L79

  @dim :faint
  @strong [:normal, :bright]

  @select :blue
  @update :yellow
  @delete :red
  @insert :green

  def run(["QUERY", "begin", "OK", _, _, _, _, _, _query, _, _]) do
    "BEGIN TRANSACTION"
  end

  def run(["QUERY", "commit", "OK", _, _, _, _, _, _query, _, _]) do
    "COMMIT TRANSACTION"
  end

  def run(["QUERY", "rollback", val, _, _, _, _, _, _query, _, _]) do
    "ROLLBACK TRANSACTION #{val}"
  end

  def run(["QUERY", _, "OK", _, _, _, _, _, query, _, params]) do
    [pretty(query) , :reset, "\n", @dim, params,"\n"] |> IO.ANSI.format
  end

  def run(["QUERY", _, "ERROR", _, _, _, _, _, query, _, params]) do
    ["ERROR:", pretty(query), :reset, "\n", @dim, params,"\n"] |> IO.ANSI.format
  end

  def run(message) do
    message
  end

  defp pretty(message) do
    message
    |> tokenize
    |> format
    |> IO.ANSI.format
  end

  defp format({:ok, tokens}) do
    format(tokens)
  end

  defp format({:error, error, original}) do
    ["ERROR PARSING ", inspect(error), " -- ", original]
  end

  defp format([]) do
    []
  end

  defp format([{:keyword, keyword = 'SELECT'}| rest]) do
    [
      [@strong, @select, keyword],
      format(rest)
    ]
  end

  defp format([{:keyword, keyword = 'INSERT'}| rest]) do
    [
      [@strong, @insert, keyword],
      format(rest)
    ]
  end

  defp format([{:keyword, keyword = 'UPDATE'}| rest]) do
    [
      [@strong, @update, keyword],
      format(rest)
    ]
  end

  defp format([{:keyword, keyword = 'DELETE'}| rest]) do
    [
      [@strong, @delete, keyword],
      format(rest)
    ]
  end

  defp format([{:keyword, keyword}| rest]) do
    [
      " ",
      [@dim, keyword],
      format(rest)
    ]
  end

  defp format([{:name, name} = tuple|rest]) do
    # look ahead
    values =
      rest
      |> Enum.take_while(fn {:name, _} -> true; {:separator} -> true; _ -> false end)

    count = length(values)
    names_count =
      values
      |> Enum.reject(fn {:separator} -> true; _ -> false end)
      |> length

    cond do
      count > 8 -> format([tuple | Enum.take(rest, 5)] ++ [{:name, "(#{names_count - 4} more)"}] ++ Enum.drop(rest, count))
      true -> [" ", cleanup(name), format(rest)]
    end
  end

  defp format([{_, value}]) do
    value
  end
  defp format([{_, value}|rest]) do
    [" ", @strong, value, format(rest)]
  end
  defp format([{:separator}]) do
    [] # invalid case
  end
  defp format([{:separator}|rest]) do
    [@dim, ",", format(rest)]
  end
  defp format([{value}]) do
    [to_string(value)]
  end
  defp format([{value}|rest]) do
    [" ", to_string(value), format(rest)]
  end

  defp cleanup(name) do
    name =
      name
      |> to_string
      |> String.replace("\"", "")

    case String.split(name, ".") do
      [prefix, suffix] -> [@dim, prefix, ".", @strong, suffix]
      _ -> [@strong, name]
    end
  end
end
