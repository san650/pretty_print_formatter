defmodule PrettyPrintFormatter.Phoenix do
  @moduledoc """
  Format phoenix's specific log messages
  """

  def run([verb, _, route]) do
    [verb, " ", route]
  end

  def run(["Sent", _, http_status, " in ", [time, unit]]) do
    ["Sent ", http_status, " in ", time, unit]
  end

  def run(["Processing with ", controller, _, action, _, _, _, "  Parameters: ", params, _, "  Pipelines: ", pipelines]) do
    [:green, " → ", :reset, controller, "#", action, :reset, :faint, " params: ", params, " pipelines: ", pipelines]
  end

  # Catch everything that we don't know how to handle
  def run(message) do
    message
  end
end
