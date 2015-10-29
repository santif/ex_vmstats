defmodule ExVmstats.Application do
  use Application

  def start(_type, _args) do
    ExVmstats.Supervisor.start_link([])
  end
end
