defmodule Rinha do
  @moduledoc """
  Documentation for `Rinha`.
  """

  def local_broadcast(topic, msg) do
    Phoenix.PubSub.local_broadcast(Rinha.PubSub, topic, msg)
  end
end
