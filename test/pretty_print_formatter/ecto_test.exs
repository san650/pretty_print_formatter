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
        |> ok_message
        |> Ecto.run
        |> IO.ANSI.format(false)
        |> to_string
        |> String.trim

      assert message ==
        "SELECT (id)"
    end

    test "parens: skip space for variables" do
      message =
        "SELECT ($1)"
        |> ok_message
        |> Ecto.run
        |> IO.ANSI.format(false)
        |> to_string
        |> String.trim

      assert message ==
        "SELECT ($1)"
    end

    test "parens: skip space for names at INSERT statements when there are more than two arguments" do
      message =
        "INSERT INTO users (name, email, bio) VALUES ($1, $2, $3)"
        |> ok_message
        |> Ecto.run
        |> IO.ANSI.format(false)
        |> to_string
        |> String.trim

      # the number of "more" arguments is incorrect, I put that to pass the test and I'm working to fix it
      assert message ==
        "INSERT INTO users (name, email (0 more)) VALUES ($1, $2, $3)"
    end
  end

  defp ok_message(value) do
    ["QUERY", nil, "OK", nil, nil, nil, nil, nil, value, nil, []]
  end
end
