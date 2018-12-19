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
  end

  defp ok_message(value) do
    ["QUERY", nil, "OK", nil, nil, nil, nil, nil, value, nil, []]
  end
end
