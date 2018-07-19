defmodule PrettyPrintFormatter.Default do
  @moduledoc """
  Default formatter used for all messages that we're not going to format
  """

  # Catch everything that we don't know how to handle
  def run(message) do
    message
  end
end
