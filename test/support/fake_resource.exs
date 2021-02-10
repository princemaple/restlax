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
