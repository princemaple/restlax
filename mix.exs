defmodule Restlax.MixProject do
  use Mix.Project

  def project do
    [
      app: :restlax,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.0"},
      {:finch, "~> 0.6", optional: true},
      {:mint, "~> 1.0", optional: true},
      {:hackney, "~> 1.0", optional: true},
      {:gun, "~> 1.0", optional: true},
      {:jason, "~> 1.0", optional: true},
      {:plug, "~> 1.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end
end
