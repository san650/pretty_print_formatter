defmodule PrettyPrintFormatter.Ecto.SqlTokenizerTest do
  use ExUnit.Case

  alias PrettyPrintFormatter.Ecto.SqlTokenizer

  doctest SqlTokenizer

  describe "tokenize/1" do
    test "basic select statement" do
      assert SqlTokenizer.tokenize("SELECT * FROM users AS u0 WHERE u0.id = 5 LIMIT 10 OFFSET 50") ==
               {:ok,
                [
                  {:keyword, 'SELECT'},
                  {:operator, '*'},
                  {:keyword, 'FROM'},
                  {:name, 'users'},
                  {:keyword, 'AS'},
                  {:name, 'u0'},
                  {:keyword, 'WHERE'},
                  {:name, 'u0.id'},
                  {:operator, '='},
                  {:integer, '5'},
                  {:keyword, 'LIMIT'},
                  {:integer, '10'},
                  {:keyword, 'OFFSET'},
                  {:integer, '50'}
                ]}
    end

    test "joins statement" do
      assert SqlTokenizer.tokenize("""
             SELECT t1.* FROM table1
             INNER JOIN table2 AS t2 ON t1.id == t2.id
             LEFT JOIN table3 AS t3 ON t1.id == t3.id
             RIGHT JOIN table4 AS t4 ON t1.id == t4.id
             """) ==
               {:ok,
                [
                  keyword: 'SELECT',
                  name: 't1.',
                  operator: '*',
                  keyword: 'FROM',
                  name: 'table1',
                  keyword: 'INNER',
                  keyword: 'JOIN',
                  name: 'table2',
                  keyword: 'AS',
                  name: 't2',
                  keyword: 'ON',
                  name: 't1.id',
                  operator: '==',
                  name: 't2.id',
                  keyword: 'LEFT',
                  keyword: 'JOIN',
                  name: 'table3',
                  keyword: 'AS',
                  name: 't3',
                  keyword: 'ON',
                  name: 't1.id',
                  operator: '==',
                  name: 't3.id',
                  keyword: 'RIGHT',
                  keyword: 'JOIN',
                  name: 'table4',
                  keyword: 'AS',
                  name: 't4',
                  keyword: 'ON',
                  name: 't1.id',
                  operator: '==',
                  name: 't4.id'
                ]}
    end

    test "basic insert statement" do
      assert SqlTokenizer.tokenize(
               "INSERT INTO \"foo\" (\"id\", \"inserted_at\") VALUES ($1,DEFAULT)"
             ) ==
               {:ok,
                [
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

    test "sqlite parameters" do
      assert SqlTokenizer.tokenize(
        "SELECT \"value\" FROM \"settings\" WHERE \"name\" = ?1 [\"hCard_note\"];"
      ) ==
        {:ok,
          [
            {:keyword, 'SELECT'},
            {:name, '"value"'},
            {:keyword, 'FROM'},
            {:name, '"settings"'},
            {:keyword, 'WHERE'},
            {:name, '"name"'},
            {:operator, '='},
            {:variable, '?1'},
            {:paren_open},
            {:name, '"hCard_note"'},
            {:paren_close},
            {:separator}
          ]}
    end
  end
end
