import Config

config :logger, level: :error

config :tesla, HttpBinCustomAdapterClient, adapter: TestAdapter
