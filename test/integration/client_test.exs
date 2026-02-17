defmodule Integration.ClientTest do
  use ExUnit.Case, async: true

  require HttpBin

  test "ok without adapter configured" do
    assert {:ok,
            %{
              body: %{
                "method" => "GET",
                "url" => HttpBin.url("/anything/endpoint")
              }
            }} = HttpBinDefaultAdapterClient.get("/endpoint")
  end

  test "with leading slash" do
    assert {:ok,
            %{
              body: %{
                "method" => "GET",
                "url" => HttpBin.url("/anything/endpoint")
              }
            }} = HttpBinClient.get("/endpoint")
  end

  test "without leading slash" do
    assert {:ok,
            %{
              body: %{
                "method" => "GET",
                "url" => HttpBin.url("/anything/endpoint")
              }
            }} = HttpBinClient.get("endpoint")
  end

  test "post json" do
    assert {:ok,
            %{
              body: %{
                "json" => %{"test" => %{"count" => 123, "data" => ["a", "b", "c"]}}
              }
            }} = HttpBinClient.post("endpoint", %{test: %{data: ~w(a b c), count: 123}})
  end

  test "patch json" do
    assert {:ok,
            %{
              body: %{
                "method" => "PATCH",
                "json" => %{"test" => %{"count" => 123}}
              }
            }} = HttpBinClient.patch("endpoint", %{test: %{count: 123}})
  end

  test "head request" do
    assert {:ok, %{body: ""}} = HttpBinClient.head("endpoint")
  end

  test "send headers" do
    assert {:ok, %{body: %{"headers" => %{"Test-Header" => "testing"}}}} =
             HttpBinClient.post("endpoint", %{}, headers: [{"test-header", "testing"}])
  end

  test "override header" do
    assert {:ok, %{body: %{"headers" => %{"Test-Header" => "test overriding"}}}} =
             HttpBinClient.post("endpoint", %{}, headers: [{"test-header", "test overriding"}])
  end

  test "interpolate path params" do
    assert {:ok, %{url: HttpBin.url("/anything/endpoint/123")}} =
             HttpBinClient.get("endpoint/:id", Restlax.Resource.handle_options(params: [id: 123]))

    assert {:ok, %{url: HttpBin.url("/anything/scope/1/endpoint/123/action/23")}} =
             HttpBinClient.post(
               "scope/:scope_id/endpoint/:id/action/:action_id",
               %{},
               Restlax.Resource.handle_options(params: [id: 123, scope_id: 1, action_id: 23])
             )
  end

  test "default auth header" do
    assert {:ok,
            %{
              body: %{
                "headers" => %{
                  "Authorization" => "Basic dGVzdDpwYXNz"
                }
              }
            }} = HttpBinBasicAuthClient.get("/endpoint")
  end

  test "bang request returns response directly" do
    assert %{
             body: %{
               "method" => "GET",
               "url" => HttpBin.url("/anything/endpoint")
             }
           } = HttpBinClient.get!("/endpoint")
  end
end
