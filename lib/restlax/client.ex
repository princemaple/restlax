defmodule Restlax.Client do
  @moduledoc """

  ## Rest Client builder

  ### Example

      defmodule MyClient do
        use Restlax.Client,
          base_url: "https://my-awesome.app/api/v1"
          adapter: Tesla.Adapter.Mint
      end
  """
  @type encoding :: :json | :form_url_encoded
  @encoding [:json, :form_url_encoded]

  @type option ::
          {:adapter, module()}
          | {:adapter_opts, keyword()}
          | {:logger_opts, keyword()}
          | {:base_url, String.t()}
          | {:encoding, encoding() | {encoding(), keyword()}}
          | {:headers, [{String.t(), String.t()}]}

  @spec __using__(opts :: [option()]) :: Macro.t()
  defmacro __using__(opts) do
    adapter = Keyword.fetch!(opts, :adapter)
    adapter_opts = Keyword.get(opts, :adapter_opts, [])

    logger_opts = Keyword.get(opts, :logger_opts, [])

    base_url = Keyword.fetch!(opts, :base_url)

    {encoding, encoding_opts} =
      case Keyword.get(opts, :encoding, :json) do
        type when type in @encoding ->
          {type, []}

        {type, opts} when type in @encoding ->
          {type, opts}
      end

    headers = Keyword.get(opts, :headers)

    quote do
      use Tesla

      adapter(unquote(adapter), unquote(adapter_opts))

      plug(Tesla.Middleware.Logger, unquote(logger_opts))

      plug(Tesla.Middleware.BaseUrl, unquote(base_url))

      plug(Tesla.Middleware.PathParams)

      case unquote(encoding) do
        :json ->
          plug(Tesla.Middleware.JSON, unquote(encoding_opts))

        :form_url_encoded ->
          plug(Tesla.Middleware.FormUrlencoded, unquote(encoding_opts))
      end

      if unquote(headers) do
        plug(Tesla.Middleware.Headers, unquote(headers))
      end
    end
  end
end
