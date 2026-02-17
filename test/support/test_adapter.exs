defmodule TestAdapter do
  @behaviour Restlax.Client

  @impl Restlax.Client
  def call(_request) do
    IO.puts("Got it in TestAdapter")
    {:ok, %{status: 200}}
  end
end
