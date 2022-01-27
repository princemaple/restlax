defmodule Restlax.Client do
  @moduledoc """

  ## Rest Client builder

  ### Options

  * `:adapter` - `module()` One of the Tesla Adapters or your own customized adapter
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
          adapter: Tesla.Adapter.Hackney
      end

  *Note: You may pick an adapter directly like in the above code. However, it's preferred to not pick one
  if your API client is a library. Leaving it out allows the users of your library to choose one
  for themselves.*

  For example, if your users already use Mint in their code base, they can use this configuration

      config :tesla, Cloudflare.Client, adapter: Tesla.Adapter.Mint

  to make the Cloudflare API client use the Mint adapter of Tesla and avoid adding another dependency

  ### Customization

  Feel free to add more middlewares like so


      defmodule MyApp.Auth do
        @behaviour Tesla.Middleware

        @impl Tesla.Middleware
        def call(env, next, _) do
          auth_token = env.opts[:auth_token] || Application.get_env(:my_app, :auth_token)
          headers = auth_token && [{"authorization", "Bearer \#{auth_token}"}]) || []
          Tesla.run(%{env | headers: headers ++ env.headers}, next)
        end
      end

      defmodule MyApp.MyClient do
        use Restlax.Client,
          base_url: "https://my-awesome.app/api/v1"
          adapter: Tesla.Adapter.Hackney

        plug MyApp.Auth
      end
  """
  @type encoding :: :json | :form_url_encoded | :raw

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

        :raw ->
          require Logger
          Logger.info("No encoding/decoding is configured for #{__MODULE__}")

        unknown ->
          raise "Unknown encoding: #{inspect(unknown)}"
      end

      if unquote(headers) do
        plug Tesla.Middleware.Headers, unquote(headers)
      end
    end
  end
end
