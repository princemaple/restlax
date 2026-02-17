Application.put_env(:bypass, :test_framework, :espec)
http_bin_bypass = Bypass.open()
System.put_env("HTTP_BIN_URL", "http://localhost:#{http_bin_bypass.port}")

for path <- Path.wildcard("#{__DIR__}/support/*.exs") do
  Code.require_file(path)
end

Bypass.expect(http_bin_bypass, fn conn ->
  headers =
    conn.req_headers
    |> Enum.into(%{}, fn {key, value} ->
      {Restlax.TestSupport.HttpBin.format_header(key), value}
    end)

  {:ok, body, conn} = Plug.Conn.read_body(conn)
  json = if body == "", do: nil, else: Jason.decode!(body)

  response =
    %{
      method: conn.method,
      url: "http://localhost:#{http_bin_bypass.port}#{conn.request_path}",
      headers: headers,
      json: json
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()

  conn
  |> Plug.Conn.put_resp_header("x-http-method", conn.method)
  |> Plug.Conn.put_resp_content_type("application/json")
  |> Plug.Conn.send_resp(200, Jason.encode!(response))
end)

:persistent_term.put({:undefined, :client}, HttpBinClient)

ExUnit.start()
