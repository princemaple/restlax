defmodule HttpBin do
  defmacro url(path \\ "") do
    System.get_env("HTTP_BIN_URL", "http://localhost") <> path
  end
end

defmodule Restlax.TestSupport.HttpBin do
  def format_header(header) do
    header
    |> String.split("-")
    |> Enum.map_join("-", &String.capitalize/1)
  end
end

defmodule HttpBinClient do
  require HttpBin

  use Restlax.Client,
    base_url: HttpBin.url("/anything")
end

defmodule HttpBinDefaultAdapterClient do
  require HttpBin

  use Restlax.Client, base_url: HttpBin.url("/anything")
end

defmodule HttpBinDefaultHeaderClient do
  require HttpBin

  use Restlax.Client,
    base_url: HttpBin.url("/anything"),
    headers: [{"test-header", "testing"}]
end

defmodule HttpBinBasicAuthClient do
  require HttpBin

  use Restlax.Client,
    base_url: HttpBin.url("/anything"),
    headers: [{"authorization", "Basic dGVzdDpwYXNz"}]
end

defmodule HttpBinFormClient do
  require HttpBin

  use Restlax.Client,
    base_url: HttpBin.url("/anything"),
    encoding: :form_url_encoded
end

defmodule HttpBinRawClient do
  require HttpBin

  use Restlax.Client,
    base_url: HttpBin.url("/anything"),
    encoding: :raw
end

defmodule HttpBinReqOptionsClient do
  require HttpBin

  use Restlax.Client,
    base_url: HttpBin.url("/anything"),
    headers: [{"test-header", "from-default"}],
    req_options: [
      headers: [{"from-req", "yes"}, {"test-header", "from-req"}],
      receive_timeout: 30_000
    ]
end

defmodule HttpBinUnavailableClient do
  use Restlax.Client,
    base_url: "http://localhost:1/anything"
end
