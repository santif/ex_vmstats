defmodule ExVmstats.TestBackend do
  require Logger

  def counter(value, metric) do
    Logger.info "counter #{inspect {value, metric}}"
  end

  def gauge(value, metric) do
    Logger.info "gauge #{inspect {value, metric}}"
  end

  def histogram(value, metric) do
    Logger.info "histogram #{inspect {value, metric}}"
  end

  def timing(value, metric) do
    Logger.info "timing #{inspect {value, metric}}"
  end
end