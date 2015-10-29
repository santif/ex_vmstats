defmodule ExVmstats.Backends.ExStatsD do
  def counter(value, metric) do
    ExStatsD.counter(value, metric, sample_size: 1)
  end

  def gauge(value, metric) do
    ExStatsD.gauge(value, metric, sample_size: 1)
  end

  def histogram(value, metric) do
    ExStatsD.histogram(value, metric, sample_size: 1)
  end

  def timing(value, metric) do
    ExStatsD.timing(value, metric, sample_size: 1)
  end
end