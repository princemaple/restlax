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

  # Adapter configured via config/config.exs
  use Restlax.Client, base_url: HttpBin.url("/anything")
end

defmodule HttpBinDefaultHeaderClient do
  require HttpBin

  use Restlax.Client,
    adapter: Tesla.Adapter.Mint,
    base_url: HttpBin.url("/anything"),
    headers: [{"test-header", "testing"}]
end

defmodule HttpBinBasicAuthClient do
  require HttpBin

  use Restlax.Client, base_url: HttpBin.url("/anything")

  @username "test"
  @password "pass"

  plug Tesla.Middleware.BasicAuth, username: @username, password: @password

  defmacro hash do
    Base.encode64("#{@username}:#{@password}")
  end
end
