defmodule PrettyPrintFormatter.Ecto do
  @moduledoc """
  Format ecto's specific log messages
  """

  # https://github.com/elixir-ecto/ecto/blob/e243ff4597ad244ae5870dc1c9d3eb86fd91a507/lib/ecto/log_entry.ex#L77-L79
  import PrettyPrintFormatter.Ecto.SqlTokenizer

  @select :blue
  @update :yellow
  @delete :red
  @insert :green

  @type opt :: {:short_params_list, boolean()}

  @spec run(arg :: term(), list(opt)) :: String.t()

  def run(arg, opts \\ [])

  def run(["QUERY", _, "OK", _, _, _, _, _, "begin", _, _], _) do
    "BEGIN TRANSACTION"
  end

  def run(["QUERY", _, "OK", _, _, _, _, _, "commit", _, _], _) do
    "COMMIT TRANSACTION"
  end

  def run(["QUERY", "rollback", val, _, _, _, _, _, _query, _, _], _) do
    "ROLLBACK TRANSACTION #{val}"
  end

  def run(["QUERY", _, "OK", _, _, _, _, _, query, _, params], opts) do
    opts = Enum.into(opts, %{})

    [pretty(query, opts), :reset, " ", :faint, params]
  end

  def run(["QUERY", _, "ERROR", _, _, _, _, _, query, _, params], _) do
    ["ERROR:", query, :reset, " ", :faint, params]
  end

  # Catch everything that we don't know how to handle
  def run(message, _) do
    message
  end

  defp pretty(message, opts) do
    message
    |> tokenize
    |> format(opts)
  end

  defp format({:ok, tokens}, opts) do
    opts =
      Map.merge(
        %{
          first: true,
          bright: false,
          skip_space: false
        },
        opts
      )

    do_format(tokens, [], opts)
  end

  defp format({:error, error, original}, _) do
    ["ERROR PARSING ", inspect(error), " -- ", original]
  end

  defp do_format(param, acc, opts)

  defp do_format([], acc, _) do
    Enum.reverse(acc)
  end

  defp do_format([{:keyword, keyword = 'SELECT'} | rest], acc, %{first: true} = opts) do
    do_format(rest, [[@select, keyword] | acc], %{opts | first: false})
  end

  defp do_format([{:keyword, keyword = 'UPDATE'} | rest], acc, %{first: true} = opts) do
    do_format(rest, [[@update, keyword] | acc], %{opts | first: false})
  end

  defp do_format([{:keyword, keyword = 'DELETE'} | rest], acc, %{first: true} = opts) do
    do_format(rest, [[@delete, keyword] | acc], %{opts | first: false})
  end

  defp do_format([{:keyword, keyword = 'INSERT'} | rest], acc, %{first: true} = opts) do
    do_format(rest, [[@insert, keyword] | acc], %{opts | first: false})
  end

  defp do_format([{:keyword, keyword} | rest], acc, opts)
       when keyword in ['FROM', 'JOIN', 'INTO'] do
    do_format(rest, [[" ", keyword, " "] | acc], %{opts | bright: true})
  end

  defp do_format([{:keyword, keyword} | rest], acc, opts) do
    do_format(rest, [[" ", [keyword]] | acc], opts)
  end

  defp do_format([{:name, name} | rest], acc, %{bright: true} = opts) do
    do_format(rest, [[:bright, cleanup(name), :normal] | acc], %{opts | bright: false})
  end

  defp do_format([{:name, name} = tuple | rest], acc, opts) do
    short_params_list = Map.get(opts, :short_params_list, false)

    # look ahead
    values =
      rest
      |> Enum.take_while(fn
        {:name, _} -> true
        {:separator} -> true
        _ -> false
      end)

    count = length(values)

    names_count =
      values
      |> Enum.reject(fn
        {:separator} -> true
        _ -> false
      end)
      |> length

    # to take into account the first name (that comes in 'tuple')
    names_count = names_count + 1

    cond do
      short_params_list and count > 2 ->
        do_format(
          [tuple | Enum.take(rest, 2)] ++ [{:counter, names_count - 2}] ++ Enum.drop(rest, count),
          acc,
          opts
        )

      true ->
        do_format(rest, [[get_prefix(opts), cleanup(name)] | acc], opts)
    end
  end

  defp do_format([{:counter, count} | rest], acc, opts) do
    do_format(
      rest,
      [[:faint, " (", :underline, "#{count} more", :no_underline, ")", :normal] | acc],
      opts
    )
  end

  defp do_format([{:separator} | rest], acc, opts) do
    do_format(rest, [[","] | acc], %{opts | skip_space: false})
  end

  defp do_format([{:paren_open} | rest], acc, opts) do
    do_format(rest, [[" ("] | acc], %{opts | skip_space: true})
  end

  defp do_format([{:paren_close} | rest], acc, opts) do
    do_format(rest, [[")"] | acc], opts)
  end

  defp do_format([{value} | rest], acc, opts) do
    do_format(rest, [[" ", to_string(value)] | acc], opts)
  end

  defp do_format([{_, value} | rest], acc, opts) do
    do_format(rest, [[get_prefix(opts), value] | acc], %{opts | skip_space: false})
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

  defp get_prefix(%{skip_space: true}) do
    ""
  end

  defp get_prefix(_) do
    " "
  end
end
