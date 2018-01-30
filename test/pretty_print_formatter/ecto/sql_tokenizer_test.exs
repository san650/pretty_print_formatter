defmodule PrettyPrintFormatter.Ecto.SqlTokenizerTest do
  use ExUnit.Case

  alias PrettyPrintFormatter.Ecto.SqlTokenizer

  doctest SqlTokenizer

  describe "tokenize/1" do
    test "basic select statement" do
      assert SqlTokenizer.tokenize("SELECT * FROM users AS u0 WHERE u0.id = 5") == {:ok, [
        {:keyword, 'SELECT'},
        {:operator, '*'},
        {:keyword, 'FROM'},
        {:name, 'users'},
        {:keyword, 'AS'},
        {:name, 'u0'},
        {:keyword, 'WHERE'},
        {:name, 'u0.id'},
        {:operator, '='},
        {:integer, '5'}
      ]}
    end
  end
end
