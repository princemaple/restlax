defmodule ResourceTest do
  use ExUnit.Case, async: true

  test "handle_options" do
    params = [id: 123, scope_id: 321]
    assert {:opts, [path_params: params]} in Restlax.Resource.handle_options(params: params)
  end

  test "handle_options with no params returns original opts" do
    opts = [headers: [{"x-test", "1"}]]
    assert Restlax.Resource.handle_options(opts) == opts
  end

  test "handle_options preserves existing opts" do
    params = [id: 123]
    opts = [opts: [raw: true], params: params]

    assert [opts: [path_params: ^params, raw: true], params: ^params] =
             Restlax.Resource.handle_options(opts)
  end
end
