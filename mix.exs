defmodule Presentator.MixProject do
  use Mix.Project

  def project do
    [
      app: :presentator,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Presentator, []},
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.9"},
      {:scenic_driver_glfw, "~> 0.9"},
      {:amqp, "~> 1.1"},
      {:jason, "~> 1.1"},
      {:fwup, "~> 0.3.0"}
    ]
  end
end
