defmodule Restlax.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/princemaple/restlax"

  def project do
    [
      app: :restlax,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Package
      name: "Restlax",
      description: "Relax, it's just REST - API Client builder",
      package: package(),
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
      {:req, "~> 0.4.0 and < 0.4.10"},
      {:ex_doc, "~> 0.40.1", only: :docs},
      {:bypass, "~> 2.1", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Po Chen"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(.formatter.exs mix.exs lib README.md CHANGELOG.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "Restlax",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/restlax",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
