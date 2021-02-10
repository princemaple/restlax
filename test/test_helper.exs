:persistent_term.put({:undefined, :client}, HttpBinClient)

for path <- Path.wildcard("#{__DIR__}/support/*.exs") do
  Code.require_file(path)
end

ExUnit.start()
