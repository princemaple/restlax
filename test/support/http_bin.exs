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
