defmodule ResourceClientTest do
  use ExUnit.Case, async: false

  setup do
    on_exit(fn ->
      Application.put_env(:restlax, :client, HttpBinClient)
      :persistent_term.erase({:restlax, :client})
    end)
  end

  test "get client from option" do
    assert FakeResource.client(client: MyClient) == MyClient
  end

  test "option overrides application client" do
    Application.put_env(:restlax, :client, NotMyClient)
    assert FakeResource.client(client: MyClient) == MyClient
  end

  test "get client from application config" do
    Application.put_env(:restlax, :client, SomeClient)
    assert FakeResource.client([]) == SomeClient
  end

  test "fallback to persistent_term" do
    Application.delete_env(:restlax, :client)
    :persistent_term.put({:restlax, :client}, SomeClient)

    assert FakeResource.client([]) == SomeClient
  end
end
