defmodule ClientTest do
  use ExUnit.Case, async: true

  defmodule CaptureAdapter do
    @behaviour Restlax.Client

    @impl Restlax.Client
    def call(request) do
      send(self(), {:request, request})
      {:ok, %{status: 200, body: %{}, headers: request.headers, url: request.url}}
    end
  end

  defmodule Client do
    use Restlax.Client, base_url: "http://localhost/base", adapter: CaptureAdapter, headers: [{"x-test", "default"}]
    plug Restlax.Client.BasicAuth, username: "user", password: "pass"
  end

  test "interpolates path params and merges headers" do
    {:ok, response} =
      Client.get(
        "endpoint/:id",
        [headers: [{"x-test", "override"}]] ++ Restlax.Resource.handle_options(params: [id: 123])
      )

    assert response.url == "http://localhost/base/endpoint/123"

    assert_received {:request, %{headers: headers, url: "http://localhost/base/endpoint/123"}}
    assert {"x-test", "override"} in headers
    assert {"authorization", "Basic dXNlcjpwYXNz"} in headers
  end
end
