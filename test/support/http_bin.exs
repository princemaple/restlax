defmodule HttpBin do
  defmacro url(path \\ "") do
    System.get_env("HTTP_BIN_URL", "http://localhost") <> path
  end
end

defmodule HttpBinClient do
  require HttpBin

  use Restlax.Client,
    adapter: Tesla.Adapter.Mint,
    base_url: HttpBin.url("/anything")
end

defmodule HttpBinDefaultAdapterClient do
  require HttpBin

  use Restlax.Client, base_url: HttpBin.url("/anything")
end

defmodule HttpBinCustomAdapterClient do
  require HttpBin

  # Adapter configured via config/test.exs
  use Restlax.Client, base_url: HttpBin.url("/anything")
end

defmodule HttpBinDefaultHeaderClient do
  require HttpBin

  use Restlax.Client,
    adapter: Tesla.Adapter.Mint,
    base_url: HttpBin.url("/anything"),
    headers: [{"test-header", "testing"}]
end

defmodule FakeResource do
  use Restlax.Resource, endpoint: "fake-resource"

  def resource_action(id, body) do
    client().put(path_for(id, action: "action"), body)
  end

  def collection_action(body) do
    client().post(path_for(nil, action: "action"), body)
  end
end

defmodule FakeNestedResource do
  use Restlax.Resource, endpoint: "fake-resource/fake-nested-resource"
end

defmodule FakeScopedResource do
  use Restlax.Resource, endpoint: "scope/:id/fake-resource"
end

defmodule FakeSingularResource do
  use Restlax.Resource, endpoint: "fake-singular-resource", singular: true
end
