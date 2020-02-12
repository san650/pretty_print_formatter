defmodule PrettyPrintFormatter.EctoTest do
  use ExUnit.Case

  alias PrettyPrintFormatter.Ecto

  doctest Ecto

  describe "run/1" do
    test "formats begin transaction message" do
      message =
        "begin"
        |> ok_message
        |> Ecto.run
        |> IO.ANSI.format
        |> to_string

      assert message == "BEGIN TRANSACTION"
    end

    @reset "\e[0m \e[2m\e[0m"

    test "coloring SELECT: maintain first keyword color" do
      message =
        "SELECT INSERT"
        |> ok_message
        |> Ecto.run
        |> IO.ANSI.format
        |> to_string

      assert message ==
        "\e[34mSELECT INSERT" <> @reset
    end

    test "coloring UPDATE: maintain first keyword color" do
      message =
        "UPDATE SELECT"
        |> ok_message
        |> Ecto.run
        |> IO.ANSI.format
        |> to_string

      assert message ==
        "\e[33mUPDATE SELECT" <> @reset
    end

    test "coloring DELETE: maintain first keyword color" do
      message =
        "DELETE SELECT"
        |> ok_message
        |> Ecto.run
        |> IO.ANSI.format
        |> to_string

      assert message ==
        "\e[31mDELETE SELECT" <> @reset
    end

    test "coloring INSERT: maintain first keyword color" do
      message =
        "INSERT SELECT"
        |> ok_message
        |> Ecto.run
        |> IO.ANSI.format
        |> to_string

      assert message ==
        "\e[32mINSERT SELECT" <> @reset
    end

    test "parens: skip space for names" do
      message =
        "SELECT (id)"
        |> statement_message

      assert message ==
        "SELECT (id)"
    end

    test "parens: skip space for variables" do
      message =
        "SELECT ($1)"
        |> statement_message

      assert message ==
        "SELECT ($1)"
    end

    test "parens: skip space for names at INSERT statements when there are more than two arguments" do
      message =
        "INSERT INTO users (name, email, bio) VALUES ($1, $2, $3)"
        |> statement_message()

      assert message ==
        "INSERT INTO users (name, email, bio) VALUES ($1, $2, $3)"
    end

    test "with [short_params_list: true] parens: skip space for names at INSERT statements when there are more than two arguments" do
      message =
        "INSERT INTO users (name, email, bio) VALUES ($1, $2, $3)"
        |> statement_message(short_params_list: true)

      assert message ==
        "INSERT INTO users (name, email (1 more)) VALUES ($1, $2, $3)"
    end

    test "with [short_params_list: true] number of 'more' arguments" do
      insert_message_four_args =
        "INSERT INTO users (name, email, bio, number_of_pets) VALUES ($1, $2, $3, $4) RETURNING id"
        |> statement_message(short_params_list: true)

      insert_message_two_args =
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id"
        |> statement_message(short_params_list: true)

      select_message_five_args =
        "SELECT id, name, email, bio, age FROM users"
        |> statement_message(short_params_list: true)

      select_message_one_arg =
        "SELECT id FROM users"
        |> statement_message(short_params_list: true)

      assert insert_message_four_args ==
        "INSERT INTO users (name, email (2 more)) VALUES ($1, $2, $3, $4) RETURNING id"

      assert insert_message_two_args ==
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id"

      assert select_message_five_args ==
        "SELECT id, name (3 more) FROM users"

      assert select_message_one_arg ==
        "SELECT id FROM users"

      assert "SELECT a, b (4 more) FROM users AS u0 where u0.id = 5" == "SELECT a, b, c, d, e, f FROM users AS u0 where u0.id = 5" |> statement_message(short_params_list: true)
    end
  end

  defp ok_message(value) do
    ["QUERY", nil, "OK", nil, nil, nil, nil, nil, value, nil, []]
  end

  defp statement_message(value, opts \\ []) do
    ["QUERY", nil, "OK", nil, nil, nil, nil, nil, value, nil, []]
      |> Ecto.run(opts)
      |> IO.ANSI.format(false)
      |> to_string
      |> String.trim
  end
end
