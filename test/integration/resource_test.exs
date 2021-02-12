defmodule Integration.ResourceTest do
  use ExUnit.Case, async: true

  require HttpBin

  test "list" do
    assert {:ok,
            %{
              body: %{"method" => "GET", "url" => HttpBin.url("/anything/fake-resource")}
            }} = FakeResource.index()

    assert %{
             body: %{"method" => "GET", "url" => HttpBin.url("/anything/fake-resource")}
           } = FakeResource.index!()
  end

  test "show" do
    assert {:ok,
            %{
              body: %{"method" => "GET", "url" => HttpBin.url("/anything/fake-resource/123")}
            }} = FakeResource.show(123)

    assert %{
             body: %{"method" => "GET", "url" => HttpBin.url("/anything/fake-resource/123")}
           } = FakeResource.show!(123)
  end

  test "create" do
    assert {:ok,
            %{
              body: %{"method" => "POST", "url" => HttpBin.url("/anything/fake-resource")}
            }} = FakeResource.create(%{})

    assert %{
             body: %{"method" => "POST", "url" => HttpBin.url("/anything/fake-resource")}
           } = FakeResource.create!(%{})
  end

  test "update" do
    assert {:ok,
            %{
              body: %{"method" => "PUT", "url" => HttpBin.url("/anything/fake-resource/123")}
            }} = FakeResource.update(123, %{})

    assert %{
             body: %{"method" => "PUT", "url" => HttpBin.url("/anything/fake-resource/123")}
           } = FakeResource.update!(123, %{})
  end

  test "delete" do
    assert {:ok,
            %{
              body: %{"method" => "DELETE", "url" => HttpBin.url("/anything/fake-resource/123")}
            }} = FakeResource.delete(123)

    assert %{
             body: %{"method" => "DELETE", "url" => HttpBin.url("/anything/fake-resource/123")}
           } = FakeResource.delete!(123)
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
            }} = FakeScopedResource.index(params: [id: 123])
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

  test "dynamically swap client" do
    assert {:ok,
            %{
              body: %{"headers" => %{"Test-Header" => "testing"}}
            }} = FakeResource.index(client: HttpBinDefaultHeaderClient)
  end

  describe "path_for" do
    test "resource, passing id" do
      assert "fake-resource/123" == FakeResource.path_for(123)
    end

    test "collection, passing nil as id" do
      assert "fake-resource" == FakeResource.path_for(nil)
    end

    test "resource action" do
      assert "fake-resource/123/test" == FakeResource.path_for(123, action: "test")
    end

    test "collection action" do
      assert "fake-resource/test" == FakeResource.path_for(nil, action: "test")
    end

    test "action with param" do
      assert "fake-resource/test/:param" == FakeResource.path_for(nil, action: "test/:param")
    end
  end
end
