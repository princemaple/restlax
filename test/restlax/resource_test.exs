defmodule ResourceTest do
  use ExUnit.Case, async: true

  test "handle_options" do
    params = [id: 123, scope_id: 321]
    assert {:opts, [path_params: params]} in Restlax.Resource.handle_options(params: params)
  end
end
