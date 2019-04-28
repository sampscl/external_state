defmodule ExternalState.MixProject do
  use Mix.Project

  def project do
    [
      app: :external_state,
      version: "1.0.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex2ms, "~> 1.0"},
      {:ets_owner, "~> 1.0"},
    ]
  end
end
