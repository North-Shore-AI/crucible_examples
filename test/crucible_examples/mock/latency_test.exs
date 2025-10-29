defmodule CrucibleExamples.Mock.LatencyTest do
  use ExUnit.Case, async: true
  alias CrucibleExamples.Mock.Latency

  describe "simulate/1" do
    test "returns positive latency for fast profile" do
      latency = Latency.simulate(:fast)
      assert latency > 0
    end

    test "returns positive latency for medium profile" do
      latency = Latency.simulate(:medium)
      assert latency > 0
    end

    test "returns positive latency for slow profile" do
      latency = Latency.simulate(:slow)
      assert latency > 0
    end

    test "fast profile is generally faster than slow" do
      fast_samples = for _ <- 1..100, do: Latency.simulate(:fast)
      slow_samples = for _ <- 1..100, do: Latency.simulate(:slow)

      fast_median = Enum.sort(fast_samples) |> Enum.at(50)
      slow_median = Enum.sort(slow_samples) |> Enum.at(50)

      assert fast_median < slow_median
    end
  end

  describe "distribution/1" do
    test "returns percentile map for fast profile" do
      dist = Latency.distribution(:fast)

      assert Map.has_key?(dist, :p0)
      assert Map.has_key?(dist, :p50)
      assert Map.has_key?(dist, :p95)
      assert Map.has_key?(dist, :p99)
      assert Map.has_key?(dist, :p100)
    end

    test "percentiles are in ascending order" do
      dist = Latency.distribution(:medium)

      assert dist.p0 <= dist.p25
      assert dist.p25 <= dist.p50
      assert dist.p50 <= dist.p75
      assert dist.p75 <= dist.p95
      assert dist.p95 <= dist.p99
      assert dist.p99 <= dist.p100
    end
  end

  describe "simulate_batch/2" do
    test "returns requested number of samples" do
      samples = Latency.simulate_batch(:fast, 50)
      assert length(samples) == 50
    end

    test "all samples are positive" do
      samples = Latency.simulate_batch(:medium, 100)
      assert Enum.all?(samples, &(&1 > 0))
    end

    test "default count is 100" do
      samples = Latency.simulate_batch(:fast)
      assert length(samples) == 100
    end
  end

  describe "percentile/2" do
    test "calculates p50 correctly" do
      latencies = [100, 200, 300, 400, 500]
      p50 = Latency.percentile(latencies, 0.5)
      assert p50 == 300
    end

    test "calculates p95 correctly" do
      latencies = Enum.to_list(1..100)
      p95 = Latency.percentile(latencies, 0.95)
      assert p95 >= 90
    end

    test "handles empty list" do
      p50 = Latency.percentile([], 0.5)
      assert p50 == 0
    end
  end

  describe "analyze/1" do
    test "returns comprehensive statistics" do
      latencies = [100, 200, 300, 400, 500]
      stats = Latency.analyze(latencies)

      assert Map.has_key?(stats, :count)
      assert Map.has_key?(stats, :mean)
      assert Map.has_key?(stats, :median)
      assert Map.has_key?(stats, :p50)
      assert Map.has_key?(stats, :p95)
      assert Map.has_key?(stats, :p99)
      assert Map.has_key?(stats, :min)
      assert Map.has_key?(stats, :max)
    end

    test "calculates mean correctly" do
      latencies = [100, 200, 300]
      stats = Latency.analyze(latencies)
      assert stats.mean == 200.0
    end

    test "identifies min and max" do
      latencies = [100, 500, 200, 400, 300]
      stats = Latency.analyze(latencies)
      assert stats.min == 100
      assert stats.max == 500
    end
  end

  describe "simulate_hedging/2" do
    test "returns tuple with latencies and winner" do
      result = Latency.simulate_hedging(:medium, 1000)
      assert {primary, _hedge, winner} = result
      assert is_integer(primary)
      assert winner in [:primary_won, :hedge_won, :primary_fast]
    end

    test "primary_fast when request completes before hedge fires" do
      # Use very high hedge delay to ensure primary is fast
      result = Latency.simulate_hedging(:fast, 10_000)
      {_primary, hedge, winner} = result
      assert winner == :primary_fast
      assert hedge == nil
    end

    test "hedge can win with appropriate delay" do
      # Run multiple times to get at least one hedge win
      results =
        for _ <- 1..100 do
          Latency.simulate_hedging(:medium, 500)
        end

      hedge_wins = Enum.count(results, fn {_, _, winner} -> winner == :hedge_won end)
      assert hedge_wins > 0
    end
  end

  describe "hedge_firing_rate/3" do
    test "returns rate between 0 and 1" do
      rate = Latency.hedge_firing_rate(:medium, 1000, 100)
      assert rate >= 0.0
      assert rate <= 1.0
    end

    test "low delay threshold results in high firing rate" do
      rate = Latency.hedge_firing_rate(:medium, 100, 100)
      assert rate > 0.5
    end

    test "high delay threshold results in low firing rate" do
      rate = Latency.hedge_firing_rate(:fast, 10_000, 100)
      assert rate < 0.5
    end
  end
end
