defmodule Restlax do
  @moduledoc File.read!("#{__DIR__}/../README.md") |> String.replace(~r/^# .+\n/, "")

  def client(opts \\ []) do
    opts[:client] || :persistent_term.get({Restlax, :rest_client})
  end
end
