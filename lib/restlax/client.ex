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
    url = build_url(config.base_url, path, path_params(opts))
    headers = merge_headers(config.headers, Keyword.get(config.req_options, :headers, []) ++ Keyword.get(opts, :headers, []))
    req_options = req_options(config.req_options, opts)

    result = req_request(method, url, headers, body, config.encoding, req_options)

    case {bang, result} do
      {false, _} -> result
      {true, {:ok, response}} -> response
      {true, {:error, error}} -> raise error
    end
  end

  defp req_request(method, url, headers, body, encoding, req_options) do
    options =
      [method: method, url: url, headers: headers]
      |> with_body(body, encoding)
      # Disable Req auto-decoding so we can use Elixir JSON (or optional Jason fallback) consistently.
      |> Keyword.put_new(:decode_body, false)
      |> Keyword.merge(req_options)

    case Req.request(options) do
      {:ok, response} ->
        {:ok,
         %{
           status: response.status,
           headers: response.headers,
           body: decode_json_body(response.body, response.headers),
           url: Map.get(response, :url, url)
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  defp with_body(options, nil, _encoding), do: options
  defp with_body(options, body, :json) do
    options
    |> Keyword.put(:body, encode_json!(body))
    |> Keyword.update(:headers, [{"content-type", "application/json"}], fn headers ->
      [{"content-type", "application/json"} | headers]
    end)
  end

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

  defp decode_json_body(body, headers) when is_binary(body) do
    if json_content_type?(headers) do
      case decode_json(body) do
        {:ok, decoded} -> decoded
        _ -> body
      end
    else
      body
    end
  end

  defp decode_json_body(body, _headers), do: body

  defp json_content_type?(headers) do
    Enum.any?(headers, fn {k, v} ->
      String.downcase(to_string(k)) == "content-type" && String.contains?(to_string(v), "application/json")
    end)
  end

  defp encode_json!(data) do
    cond do
      Code.ensure_loaded?(JSON) and function_exported?(JSON, :encode!, 1) ->
        JSON.encode!(data)

      Code.ensure_loaded?(Jason) and function_exported?(Jason, :encode!, 1) ->
        Jason.encode!(data)

      true ->
        raise "JSON encoder not available. Add :jason dependency or use Elixir JSON module."
    end
  end

  defp decode_json(data) do
    cond do
      Code.ensure_loaded?(JSON) and function_exported?(JSON, :decode, 1) ->
        JSON.decode(data)

      Code.ensure_loaded?(Jason) and function_exported?(Jason, :decode, 1) ->
        Jason.decode(data)

      true ->
        {:error, :json_decoder_not_available}
    end
  end
end
