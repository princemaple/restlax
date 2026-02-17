defmodule ResourceClientTest do
  use ExUnit.Case, async: false

  setup do
    on_exit(fn ->
      Application.put_env(:undefined, :client, HttpBinClient)
      :persistent_term.erase({:undefined, :client})
    end)
  end

  test "get client from option" do
    assert FakeResource.client(client: MyClient) == MyClient
  end

  test "option overrides application client" do
    Application.put_env(:undefined, :client, NotMyClient)
    assert FakeResource.client(client: MyClient) == MyClient
  end

  test "get client from application config" do
    Application.put_env(:undefined, :client, SomeClient)
    assert FakeResource.client([]) == SomeClient
  end

  test "fallback to persistent_term" do
    Application.delete_env(:undefined, :client)
    :persistent_term.put({:undefined, :client}, SomeClient)

    assert FakeResource.client([]) == SomeClient
  end
end
