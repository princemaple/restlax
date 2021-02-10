:persistent_term.put({Restlax, :rest_client}, HttpBinClient)

Code.require_file("support/http_bin.exs", __DIR__)
ExUnit.start()
