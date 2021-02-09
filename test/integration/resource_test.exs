defmodule ResourceTest do
  use ExUnit.Case, async: true

  require HttpBin

  setup_all do
    Application.put_env(:testing, :rest_client, HttpBinClient)
  end

  test "list" do
    assert {:ok,
            %{
              body: %{"method" => "GET", "url" => HttpBin.url("/anything/fake-resource")}
            }} = FakeResource.index()
  end

  test "show" do
    assert {:ok,
            %{
              body: %{"method" => "GET", "url" => HttpBin.url("/anything/fake-resource/123")}
            }} = FakeResource.show(123)
  end

  test "create" do
    assert {:ok,
            %{
              body: %{"method" => "POST", "url" => HttpBin.url("/anything/fake-resource")}
            }} = FakeResource.create(%{})
  end

  test "update" do
    assert {:ok,
            %{
              body: %{"method" => "PUT", "url" => HttpBin.url("/anything/fake-resource/123")}
            }} = FakeResource.update(123, %{})
  end

  test "delete" do
    assert {:ok,
            %{
              body: %{"method" => "DELETE", "url" => HttpBin.url("/anything/fake-resource/123")}
            }} = FakeResource.delete(123)
  end

  test "resource action" do
    assert {:ok,
            %{
              body: %{
                "method" => "PUT",
                "url" => HttpBin.url("/anything/fake-resource/123/action"),
                "json" => %{"x" => 1}
              }
            }} = FakeResource.resource_action(123, %{x: 1})
  end

  test "collection action" do
    assert {:ok,
            %{
              body: %{
                "method" => "POST",
                "url" => HttpBin.url("/anything/fake-resource/action"),
                "json" => %{"x" => 1}
              }
            }} = FakeResource.collection_action(%{x: 1})
  end

  test "nested resource" do
    assert {:ok,
            %{
              body: %{
                "method" => "GET",
                "url" => HttpBin.url("/anything/fake-resource/fake-nested-resource")
              }
            }} = FakeNestedResource.index()
  end

  test "scoped resource" do
    assert {:ok,
            %{
              body: %{
                "method" => "GET",
                "url" => HttpBin.url("/anything/scope/123/fake-resource")
              }
            }} = FakeScopedResource.index(opts: [path_params: [id: 123]])
  end

  describe "singular resource" do
    test "show" do
      assert {:ok,
              %{
                body: %{
                  "method" => "GET",
                  "url" => HttpBin.url("/anything/fake-singular-resource")
                }
              }} = FakeSingularResource.show()
    end

    test "update" do
      assert {:ok,
              %{
                body: %{
                  "method" => "PUT",
                  "url" => HttpBin.url("/anything/fake-singular-resource")
                }
              }} = FakeSingularResource.update(%{})
    end
  end
end
