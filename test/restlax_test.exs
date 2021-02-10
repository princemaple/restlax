defmodule RestlaxTest do
  use ExUnit.Case, async: false
  doctest Restlax

  test "get client from option" do
    assert Restlax.client(client: MyClient) == MyClient
  end

  test "option overrides persistent_term" do
    :persistent_term.put({Restlax, :rest_client}, NotMyClient)
    assert Restlax.client(client: MyClient) == MyClient
    :persistent_term.erase({Restlax, :rest_client})
  end

  test "get client persistent_term" do
    :persistent_term.put({Restlax, :rest_client}, SomeClient)
    assert Restlax.client([]) == SomeClient
  end
end
