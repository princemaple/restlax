defmodule Restlax.Client do
  @moduledoc """

  ## Rest Client builder

  ### Options

  * `:base_url` - `String.t()` Base URL, e.g. "https://api.cloudflare.com/client/v4"
  * `:encoding` - `encoding()` `:json` or `:form_urlencoded`
  * `:headers` - `[{String.t(), String.t()}]` Default headers, can be overridden per request
  * `:req_options` - `keyword()` Req options that are applied to all requests

  ### Example

      defmodule MyClient do
        use Restlax.Client,
          base_url: "https://my-awesome.app/api/v1",
          req_options: [receive_timeout: 30_000]
      end
  """
  @type encoding :: :json | :form_url_encoded | :raw

  @type option ::
          {:base_url, String.t()}
          | {:encoding, encoding()}
          | {:headers, [{String.t(), String.t()}]}
          | {:req_options, keyword()}

  @spec __using__(opts :: [option()]) :: Macro.t()
  defmacro __using__(opts) do
    base_url = Keyword.fetch!(opts, :base_url)

    encoding = Keyword.get(opts, :encoding, :json)

    headers = Keyword.get(opts, :headers, [])
    req_options = Keyword.get(opts, :req_options, [])

    quote do
      @restlax_base_url unquote(base_url)
      @restlax_encoding unquote(encoding)
      @restlax_headers unquote(headers)
      @restlax_req_options unquote(req_options)

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

      def req(request), do: request

      defoverridable req: 1

      def __restlax_config__ do
        %{
          base_url: @restlax_base_url,
          encoding: @restlax_encoding,
          headers: @restlax_headers,
          req_options: @restlax_req_options
        }
      end
    end
  end

  @spec request(module(), atom(), String.t(), term(), keyword(), boolean()) :: {:ok, map()} | map() | no_return()
  def request(module, method, path, body, opts, bang) do
    config = module.__restlax_config__()
    path_params = path_params(opts)
    url = build_url(config.base_url, path)
    headers = merge_headers(config.headers, Keyword.get(config.req_options, :headers, []) ++ Keyword.get(opts, :headers, []))
    req_options = req_options(config.req_options, opts)
    request = req_request(method, url, headers, body, config.encoding, req_options, path_params)
    request = module.req(request)

    result = send_request(request, url)

    case {bang, result} do
      {false, _} -> result
      {true, {:ok, response}} -> response
      {true, {:error, error}} -> raise error
    end
  end

  defp req_request(method, url, headers, body, encoding, req_options, path_params) do
    options =
      [method: method, url: url, headers: headers, path_params: path_params]
      |> with_body(body, encoding)
      |> Keyword.merge(req_options)

    options
    |> Req.new()
    |> Req.Steps.put_path_params()
  end

  defp send_request(request, fallback_url) do
    case Req.request(request) do
      {:ok, response} ->
        {:ok,
         %{
           status: response.status,
           headers: response.headers,
           body: response.body,
           url: format_url(request.url || Map.get(response, :url) || fallback_url)
         }}

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

  defp req_options(client_req_options, request_opts) do
    request_req_options = Keyword.drop(request_opts, [:headers, :opts, :params, :client])
    client_req_options = Keyword.delete(client_req_options, :headers)
    Keyword.merge(client_req_options, request_req_options)
  end

  defp build_url(base_url, path) do
    base_url
    |> URI.parse()
    |> Map.update!(:path, &Path.join(&1 || "/", path))
    |> URI.to_string()
  end

  defp format_url(%URI{} = url), do: URI.to_string(url)
  defp format_url(url), do: url

  defp merge_headers(default_headers, headers) do
    default_headers
    |> Enum.concat(headers)
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, String.downcase(k), {k, v}) end)
    |> Map.values()
  end

end
