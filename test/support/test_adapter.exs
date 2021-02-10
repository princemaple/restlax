defmodule TestAdapter do
  @behaviour Tesla.Adapter

  @impl Tesla.Adapter
  def call(env, _opts) do
    IO.puts("Got it in TestAdapter")
    {:ok, %{env | status: 200}}
  end
end
