defmodule Restlax.Client do
  @moduledoc """

  ## Rest Client builder

  ### Options

  * `:adapter` - `module()` an optional custom adapter module implementing `c:call/1`
  * `:adapter_opts` - `keyword()` options for the adapter
  * `:base_url` - `String.t()` Base URL, e.g. "https://api.cloudflare.com/client/v4"
  * `:encoding` - `encoding()` `:json` or `:form_urlencoded`
  * `:headers` - `[{String.t(), String.t()}]` Default headers, can be overridden per request

  ### Example

      defmodule MyClient do
        use Restlax.Client,
          base_url: "https://my-awesome.app/api/v1"
          adapter: MyCustomAdapter
      end
  """
  @type encoding :: :json | :form_url_encoded | :raw

  @type option ::
          {:adapter, module()}
          | {:adapter_opts, keyword()}
          | {:base_url, String.t()}
          | {:encoding, encoding()}
          | {:headers, [{String.t(), String.t()}]}

  @type request :: %{
          method: atom(),
          url: String.t(),
          headers: [{String.t(), String.t()}],
          body: term(),
          options: keyword()
        }

  @callback call(request()) :: {:ok, map()} | {:error, term()}

  @spec __using__(opts :: [option()]) :: Macro.t()
  defmacro __using__(opts) do
    adapter = Keyword.get(opts, :adapter)
    adapter_opts = Keyword.get(opts, :adapter_opts, [])

    base_url = Keyword.fetch!(opts, :base_url)

    encoding = Keyword.get(opts, :encoding, :json)

    headers = Keyword.get(opts, :headers, [])

    quote do
      Module.register_attribute(__MODULE__, :restlax_plugs, accumulate: true, persist: true)
      import Restlax.Client, only: [plug: 1, plug: 2]

      @restlax_adapter unquote(adapter)
      @restlax_adapter_opts unquote(adapter_opts)
      @restlax_base_url unquote(base_url)
      @restlax_encoding unquote(encoding)
      @restlax_headers unquote(headers)

      def get(path, opts \\ []), do: Restlax.Client.request(__MODULE__, :get, path, nil, opts, false)
      def get!(path, opts \\ []), do: Restlax.Client.request(__MODULE__, :get, path, nil, opts, true)
      def delete(path, opts \\ []), do: Restlax.Client.request(__MODULE__, :delete, path, nil, opts, false)
      def delete!(path, opts \\ []), do: Restlax.Client.request(__MODULE__, :delete, path, nil, opts, true)
      def head(path, opts \\ []), do: Restlax.Client.request(__MODULE__, :head, path, nil, opts, false)
      def head!(path, opts \\ []), do: Restlax.Client.request(__MODULE__, :head, path, nil, opts, true)
      def post(path, body, opts \\ []), do: Restlax.Client.request(__MODULE__, :post, path, body, opts, false)
      def post!(path, body, opts \\ []), do: Restlax.Client.request(__MODULE__, :post, path, body, opts, true)
      def put(path, body, opts \\ []), do: Restlax.Client.request(__MODULE__, :put, path, body, opts, false)
      def put!(path, body, opts \\ []), do: Restlax.Client.request(__MODULE__, :put, path, body, opts, true)
      def patch(path, body, opts \\ []), do: Restlax.Client.request(__MODULE__, :patch, path, body, opts, false)
      def patch!(path, body, opts \\ []), do: Restlax.Client.request(__MODULE__, :patch, path, body, opts, true)

      def __restlax_config__ do
        plugs = Keyword.get(__MODULE__.__info__(:attributes), :restlax_plugs, [])

        %{
          adapter: @restlax_adapter,
          adapter_opts: @restlax_adapter_opts,
          base_url: @restlax_base_url,
          encoding: @restlax_encoding,
          headers: @restlax_headers,
          plugs: plugs
        }
      end
    end
  end

  @spec plug(module()) :: Macro.t()
  @spec plug(module(), keyword()) :: Macro.t()
  defmacro plug(module, opts \\ []) do
    quote do
      @restlax_plugs {unquote(module), unquote(opts)}
    end
  end

  @spec request(module(), atom(), String.t(), term(), keyword(), boolean()) :: {:ok, map()} | map() | no_return()
  def request(module, method, path, body, opts, bang) do
    config = module.__restlax_config__()
    url = build_url(config.base_url, path, path_params(opts))
    headers = merge_headers(config.headers, headers_from_plugs(config.plugs) ++ Keyword.get(opts, :headers, []))

    request = %{method: method, url: url, headers: headers, body: body, options: opts}

    result =
      case adapter(module, config) do
        nil -> req_request(request, config.encoding)
        adapter_module -> adapter_module.call(%{request | options: [adapter_opts: config.adapter_opts | opts]})
      end

    case {bang, result} do
      {false, _} -> result
      {true, {:ok, response}} -> response
      {true, {:error, error}} -> raise error
    end
  end

  defp req_request(request, encoding) do
    options =
      [method: request.method, url: request.url, headers: request.headers]
      |> with_body(request.body, encoding)

    case Req.request(options) do
      {:ok, response} ->
        {:ok, %{status: response.status, headers: response.headers, body: response.body, url: request.url}}

      {:error, error} ->
        {:error, error}
    end
  end

  defp with_body(options, nil, _encoding), do: options
  defp with_body(options, body, :json), do: Keyword.put(options, :json, body)
  defp with_body(options, body, :form_url_encoded), do: Keyword.put(options, :form, body)
  defp with_body(options, body, _encoding), do: Keyword.put(options, :body, body)

  defp path_params(opts) do
    Keyword.get(Keyword.get(opts, :opts, []), :path_params, [])
  end

  defp build_url(base_url, path, path_params) do
    path =
      path
      |> to_string()
      |> interpolate(path_params)
      |> String.trim_leading("/")

    "#{String.trim_trailing(base_url, "/")}/#{path}"
  end

  defp interpolate(path, path_params) do
    Enum.reduce(path_params, path, fn {k, v}, acc ->
      String.replace(acc, ":#{k}", to_string(v))
    end)
  end

  defp merge_headers(default_headers, headers) do
    default_headers
    |> Enum.concat(headers)
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, String.downcase(k), {k, v}) end)
    |> Map.values()
  end

  defp headers_from_plugs(plugs) do
    Enum.flat_map(plugs, fn
      {Restlax.Client.BasicAuth, opts} -> Restlax.Client.BasicAuth.headers(opts)
      _ -> []
    end)
  end

  defp adapter(module, config) do
    config.adapter ||
      Keyword.get(Application.get_env(:restlax, module, []), :adapter)
  end
end

defmodule Restlax.Client.BasicAuth do
  @spec headers(keyword()) :: [{String.t(), String.t()}]
  def headers(opts) do
    username = Keyword.fetch!(opts, :username)
    password = Keyword.fetch!(opts, :password)
    [{"authorization", "Basic #{Base.encode64("#{username}:#{password}")}"}]
  end
end
