defmodule ResourceClientTest do
  use ExUnit.Case, async: false

  setup do
    on_exit(fn ->
      :persistent_term.put({:undefined, :client}, HttpBinClient)
    end)
  end

  test "get client from option" do
    assert FakeResource.client(client: MyClient) == MyClient
  end

  test "option overrides persistent_term" do
    :persistent_term.put({:undefined, :client}, NotMyClient)
    assert FakeResource.client(client: MyClient) == MyClient
  end

  test "get client persistent_term" do
    :persistent_term.put({:undefined, :client}, SomeClient)
    assert FakeResource.client([]) == SomeClient
  end
end
