defmodule ExVmstatsTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  @metric_regexes [
    ~r/proc_count/,
    ~r/proc_limit/,
    ~r/messages_in_queues/,
    ~r/modules/,
    ~r/run_queue/,
    ~r/error_logger_queue_len/,
    ~r/io.bytes_in/,
    ~r/io.bytes_out/,
    ~r/gc.count/,
    ~r/gc.words_reclaimed/,
    ~r/reductions/,
    ~r/memory.total/,
    ~r/memory.processes_used/,
    ~r/memory.atom_used/,
    ~r/memory.binary/,
    ~r/memory.ets/
  ]

  @number_of_metrics length(@metric_regexes)

  setup do
    Application.put_env(:ex_vmstats, :backend, ExVmstats.TestBackend)
    Application.put_env(:ex_vmstats, :interval, 500)

    Supervisor.terminate_child(ExVmstats.Supervisor, ExVmstats)

    :ok
  end

  test "no stats sent before timeout" do
    capture = capture_log fn ->
      run_and_terminate_server(400)
    end

    assert capture == ""
  end

  test "single set of stats is sent after timeout" do
    capture = capture_log fn ->
      run_and_terminate_server(600)
    end

    for regex <- @metric_regexes do
      assert match_count(regex, capture) == 1
    end

    assert match_count(~r/(gauge|counter)/, capture) == @number_of_metrics
  end

  test "two sets of stats are sent after two timeouts" do
    capture = capture_log fn ->
      run_and_terminate_server(1200)
    end

    for regex <- @metric_regexes do
      assert match_count(regex, capture) == 2
    end

    assert match_count(~r/(gauge|counter)/, capture) == @number_of_metrics * 2
  end

  test "use_histogram" do
    Application.put_env(:ex_vmstats, :use_histogram, true)

    capture = capture_log fn ->
      run_and_terminate_server(600)
    end

    assert match_count(~r/histogram/, capture) == 11
    assert match_count(~r/gauge/, capture) == 0

    Application.put_env(:ex_vmstats, :use_histogram, false)
  end

  test "sched_time enabled" do
    Application.put_env(:ex_vmstats, :sched_time, true)

    capture = capture_log fn ->
      run_and_terminate_server(600)
    end

    assert match_count(~r/timing/, capture) == 16
    assert match_count(~r/scheduler_wall_time.\d(.active|.total)/, capture) == 16

    Application.put_env(:ex_vmstats, :sched_time, false)
  end

  defp match_count(regex, string) do
    Regex.scan(regex, string)
    |> length
  end

  defp run_and_terminate_server(sleep_time) do
    Supervisor.restart_child(ExVmstats.Supervisor, ExVmstats)
    :timer.sleep(sleep_time)
    Supervisor.terminate_child(ExVmstats.Supervisor, ExVmstats)
  end
end
