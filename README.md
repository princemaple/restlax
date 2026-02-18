# Restlax
[![hex.pm](https://img.shields.io/hexpm/v/restlax.svg)](https://hex.pm/packages/restlax)
[![hex.pm](https://img.shields.io/hexpm/l/restlax.svg)](https://hex.pm/packages/restlax)
[![github.com](https://img.shields.io/github/last-commit/princemaple/restlax.svg)](https://github.com/princemaple/restlax)

> Relax, it's just REST.

Built on top of [Req](https://github.com/wojtekmach/req) for a consistent HTTP transport.

## Features

- quick generation of regular REST actions
- helpers to aid writing custom actions
- request-level customization via `req/1` callback

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `restlax` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:restlax, "~> 1.0.0"}
  ]
end
```

## Usage

See `Restlax.Client` and `Restlax.Resource` for more information

The docs can be found at [https://hexdocs.pm/restlax](https://hexdocs.pm/restlax).

An example project using `Restlax`: [`Cloudflare`](https://hexdocs.pm/cloudflare)
