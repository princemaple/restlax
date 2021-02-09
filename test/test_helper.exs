:persistent_term.put(:rest_client, HttpBinClient)

Code.require_file("support/http_bin.exs", __DIR__)
ExUnit.start()
