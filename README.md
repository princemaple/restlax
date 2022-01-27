# Restlax
[![hex.pm](https://img.shields.io/hexpm/v/restlax.svg)](https://hex.pm/packages/restlax)
[![hex.pm](https://img.shields.io/hexpm/l/restlax.svg)](https://hex.pm/packages/restlax)
[![github.com](https://img.shields.io/github/last-commit/princemaple/restlax.svg)](https://github.com/princemaple/restlax)

> Relax, it's just REST.

Built on top of [Tesla](https://github.com/teamon/tesla) and allows you and the users your API client
to pick the HTTP client.

## Features

- quick generation of regular REST actions
- helpers to aid writing custom actions
- freedom of choosing your preferred HTTP client
- (Planned) request validation hook
- (Planned) response conversion hook

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `restlax` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:restlax, "~> 0.1.0"}
  ]
end
```

## Usage

See `Restlax.Client` and `Restlax.Resource` for more information

The docs can be found at [https://hexdocs.pm/restlax](https://hexdocs.pm/restlax).

An example project using `Restlax`: [`Cloudflare`](https://hexdocs.pm/cloudflare)
