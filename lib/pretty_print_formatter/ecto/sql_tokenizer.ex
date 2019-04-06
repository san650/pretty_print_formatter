defmodule PrettyPrintFormatter.Ecto.SqlTokenizer do
  @moduledoc """
  SQL Tokenizer functions
  """

  @doc """
  Tokenize an SQL expression

  ## Examples

      iex> PrettyPrintFormatter.Ecto.SqlTokenizer.tokenize("SELECT * FROM users")
      {:ok, [{:keyword, 'SELECT'}, {:operator, '*'}, {:keyword, 'FROM'}, {:name, 'users'}]}

      iex> PrettyPrintFormatter.Ecto.SqlTokenizer.tokenize("&&&")
      {:error, {1, :sql_lexer, {:illegal, '&'}}, "&&&"}
  """
  @spec tokenize(binary) ::
          {:ok, list()} | {:error, {number(), atom(), {atom(), char()}}, binary()}
  def tokenize(str) do
    str
    |> to_charlist
    |> :sql_lexer.string
    |> case do
      {:ok, tokens, _} -> {:ok, tokens |> Enum.map(& Tuple.delete_at(&1, 1))}
      {:error, error, _} -> {:error, error, str}
    end
  end
end
