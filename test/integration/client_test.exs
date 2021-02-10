defmodule ClientTest do
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

  test "ok with custom adapter configured via Application env" do
    import ExUnit.CaptureIO

    capture_io("Got it in TestAdapter", fn ->
      assert {:ok, _} = HttpBinCustomAdapterClient.get("/endpoint")
    end)
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

  test "send headers" do
    assert {:ok, %{body: %{"headers" => %{"Test-Header" => "testing"}}}} =
             HttpBinClient.post("endpoint", %{}, headers: [{"test-header", "testing"}])
  end

  test "override header" do
    assert {:ok, %{body: %{"headers" => %{"Test-Header" => "test overriding"}}}} =
             HttpBinClient.post("endpoint", %{}, headers: [{"test-header", "test overriding"}])
  end

  test "interpolate path params" do
    assert {:ok, %{url: "http://localhost/anything/endpoint/123"}} =
             HttpBinClient.post("endpoint/:id", %{}, opts: [path_params: [id: 123]])
  end
end
