defmodule PrettyPrintFormatter.Ecto do
  @moduledoc """
  Format ecto's specific log messages
  """

  # https://github.com/elixir-ecto/ecto/blob/e243ff4597ad244ae5870dc1c9d3eb86fd91a507/lib/ecto/log_entry.ex#L77-L79
  import PrettyPrintFormatter.Ecto.SqlTokenizer

  @select "\e[34m"
  @update "\e[33m"
  @delete "\e[31m"
  @insert "\e[32m"

  def run(["QUERY", _, "OK", _, _, _, _, _, "begin", _, _]) do
    "BEGIN TRANSACTION"
  end

  def run(["QUERY", _, "OK", _, _, _, _, _, "commit", _, _]) do
    "COMMIT TRANSACTION"
  end

  def run(["QUERY", "rollback", val, _, _, _, _, _, _query, _, _]) do
    "ROLLBACK TRANSACTION #{val}"
  end

  def run(["QUERY", _, "OK", _, _, _, _, _, query, _, params]) do
    [pretty(query) , :reset, " ", :faint, params]
  end

  def run(["QUERY", _, "ERROR", _, _, _, _, _, query, _, params]) do
    ["ERROR:", pretty(query), :reset, " ", :faint, params]
  end

  # Catch everything that we don't know how to handle
  def run(message) do
    message
  end

  defp pretty(message) do
    message
    |> tokenize
    |> format
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
      [@select, keyword],
      format(rest)
    ]
  end

  defp format([{:keyword, keyword = 'UPDATE'}| rest]) do
    [
      [@update, keyword],
      format(rest)
    ]
  end

  defp format([{:keyword, keyword = 'DELETE'}| rest]) do
    [
      [@delete, keyword],
      format(rest)
    ]
  end

  defp format([{:keyword, keyword = 'INSERT'}| rest]) do
    [
      [@insert, keyword],
      format(rest)
    ]
  end

  defp format([{:keyword, keyword} | rest]) when keyword in ['FROM', 'JOIN', 'INTO'] do
    [
      " ",
      keyword,
      " ",
      format(rest, :bright)
    ]
  end

  defp format([{:keyword, keyword}| rest]) do
    [
      " ",
      [keyword],
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
      # count > 8 -> format([tuple | Enum.take(rest, 5)] ++ [{:counter, names_count - 4}] ++ Enum.drop(rest, count))
      count > 2 -> format([tuple | Enum.take(rest, 2)] ++ [{:counter, names_count - 2}] ++ Enum.drop(rest, count))
      true -> [" ", cleanup(name), format(rest)]
    end
  end

  defp format([{:counter, count} | rest]) do
    [:faint, " (", :underline, "#{count} more", :no_underline, ")", :normal, format(rest)]
  end

  defp format([{_, value} | rest]) do
    [" ", value, format(rest)]
  end

  defp format([{:separator} | rest]) do
    [",", format(rest)]
  end

  defp format([{:paren_open} | rest]) do
    [" (", format(rest)]
  end

  defp format([{:paren_close} | rest]) do
    [")", format(rest)]
  end

  defp format([{value} | rest]) do
    [" ", to_string(value), format(rest)]
  end

  defp format([{:name, name} | rest], :bright) do
    [:bright, cleanup(name), :normal, format(rest)]
  end

  defp format(rest, _) do
    format(rest)
  end

  defp cleanup(name) do
    name =
      name
      |> to_string
      |> String.replace("\"", "")

    case String.split(name, ".") do
      [prefix, suffix] -> [:faint, prefix, ".", :normal, suffix]
      _ -> [name]
    end
  end
end
