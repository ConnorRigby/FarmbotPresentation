defmodule Presentator do
  @moduledoc """
  Starter application using the Scenic framework.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    {:ok, _} = Node.start(:presentation@localhost)
    true = Node.set_cookie(:democookie)

    spawn(fn ->
      Node.connect(:"presentor_fw@presentor_fw.local")
      |> IO.inspect(label: "Camera Connect")
    end)

    # Node.connect(:"farmbot@farmbot.local")
    # |> IO.inspect(label: "Farmbot Connect")

    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:presentator, :viewport)

    # start the application with the viewport
    children = [
      supervisor(Scenic, viewports: [main_viewport_config])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
