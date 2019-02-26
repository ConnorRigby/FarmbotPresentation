defmodule PresentorFw do
  @moduledoc """
  Documentation for PresentorFw.
  """

  def connect do
    true = Node.connect(presentation_node())
  end

  def send(msg) do
    :rpc.call(presentation_node(), Kernel, :send, [Presentator.Scene.Home, msg])
  end

  def presentation_node do
    :"presentation@192.168.1.123"
  end
end
