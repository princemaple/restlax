import Config

if config_env() == :test do
  config :logger, level: :error
  config :restlax, HttpBinCustomAdapterClient, adapter: TestAdapter
end
