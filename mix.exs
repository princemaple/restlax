defmodule Restlax.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/princemaple/restlax"

  def project do
    [
      app: :restlax,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
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

  defp docs do
    [
      main: "Restlax",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/restlax",
      source_url: @source_url
    ]
  end
end
