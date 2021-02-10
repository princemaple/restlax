defmodule Restlax.Client do
  @moduledoc """

  ## Rest Client builder

  ### Options

  * `:adapter` - `module()` One of the Tesla Adapters or your own customzied adapter
  * `:adapter_opts` - `keyword()` options for the adapter
  * `:logger_opts` - `keyword()` options for `Tesla.Middleware.Logger`
  * `:base_url` - `String.t()` Base URL, e.g. "https://api.cloudflare.com/client/v4"
  * `:encoding` - `encoding()` `:json` or `:form_urlencoded`
  * `:encoding_opts` - `keyword()` options for `Tesla.Middleware.JSON` or `Tesla.Middle.FormUrlencoded`
  * `:headers` - `[{String.t(), String.t()}]` Default headers, can be overridden per request

  ### Example

      defmodule MyClient do
        use Restlax.Client,
          base_url: "https://my-awesome.app/api/v1"
          adapter: Tesla.Adapter.Mint
      end
  """
  @type encoding :: :json | :form_url_encoded

  @type option ::
          {:adapter, module()}
          | {:adapter_opts, keyword()}
          | {:logger_opts, keyword()}
          | {:base_url, String.t()}
          | {:encoding, encoding()}
          | {:encoding_opts, keyword()}
          | {:headers, [{String.t(), String.t()}]}

  @spec __using__(opts :: [option()]) :: Macro.t()
  defmacro __using__(opts) do
    adapter = Keyword.get(opts, :adapter)
    adapter_opts = Keyword.get(opts, :adapter_opts, [])

    logger_opts = Keyword.get(opts, :logger_opts, [])

    base_url = Keyword.fetch!(opts, :base_url)

    encoding = Keyword.get(opts, :encoding, :json)
    encoding_opts = Keyword.get(opts, :encoding_opts, [])

    headers = Keyword.get(opts, :headers)

    quote do
      use Tesla

      if unquote(adapter) do
        adapter unquote(adapter), unquote(adapter_opts)
      end

      plug Tesla.Middleware.Logger, unquote(logger_opts)

      plug Tesla.Middleware.BaseUrl, unquote(base_url)

      plug Tesla.Middleware.PathParams

      case unquote(encoding) do
        :json ->
          plug Tesla.Middleware.JSON, unquote(encoding_opts)

        :form_url_encoded ->
          plug Tesla.Middleware.FormUrlencoded, unquote(encoding_opts)

        unknown ->
          raise "Unknown encoding: #{inspect(unknown)}"
      end

      if unquote(headers) do
        plug Tesla.Middleware.Headers, unquote(headers)
      end
    end
  end
end
