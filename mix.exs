defmodule ExternalState.MixProject do
  use Mix.Project

  def project do
    [
      app: :external_state,
      version: "1.0.6",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/sampscl/external_state",
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
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  def description do
    """
    Store state, as a properties structure, externally to a process. This is
    particularly useful when you have a genserver that both provides status to
    other genservers (e.g. "I'm working on xyz" or "I'm idle") but also has
    long-running work that it's doing.
    """
  end

  defp package do
    [
      maintainers: ["Clay Sampson"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sampscl/external_state"}
    ]
    end
  end
