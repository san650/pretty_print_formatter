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

    test "basic insert statement" do
      assert SqlTokenizer.tokenize("INSERT INTO \"foo\" (\"id\", \"inserted_at\") VALUES ($1,DEFAULT)") ==  {:ok, [
        {:keyword, 'INSERT'},
        {:keyword, 'INTO'},
        {:name, '"foo"'},
        {:paren_open},
        {:name, '"id"'},
        {:separator},
        {:name, '"inserted_at"'},
        {:paren_close},
        {:keyword, 'VALUES'},
        {:paren_open},
        {:variable, '$1'},
        {:separator},
        {:keyword, 'DEFAULT'},
        {:paren_close}
      ]}
    end
  end
end
