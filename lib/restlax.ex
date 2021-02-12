defmodule Restlax do
  @readme_path "README.md"
  @external_resource @readme_path
  @moduledoc File.read!(@readme_path) |> String.replace(~r/^# .+?\n/, "")
end
