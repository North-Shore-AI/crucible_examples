defmodule CrucibleExamples.Mock.Latency do
  @moduledoc """
  Realistic latency simulation for mock LLM models.

  Simulates three latency profiles based on real-world LLM API data:
  - Fast: P50=200ms, P95=800ms, P99=2000ms
  - Medium: P50=500ms, P95=2000ms, P99=5000ms
  - Slow: P50=1000ms, P95=4000ms, P99=8000ms

  Includes tail latency simulation (10% of requests are slow).
  """

  @latency_profiles %{
    fast: %{
      p50: 200,
      p95: 800,
      p99: 2000,
      tail_probability: 0.10
    },
    medium: %{
      p50: 500,
      p95: 2000,
      p99: 5000,
      tail_probability: 0.10
    },
    slow: %{
      p50: 1000,
      p95: 4000,
      p99: 8000,
      tail_probability: 0.12
    }
  }

  @doc """
  Simulate latency for a given profile.

  Returns latency in milliseconds.
  """
  def simulate(profile_name) when is_atom(profile_name) do
    profile = Map.fetch!(@latency_profiles, profile_name)
    simulate_with_profile(profile)
  end

  @doc """
  Simulate latency with custom profile.
  """
  def simulate_with_profile(profile) do
    rand_val = :rand.uniform()

    cond do
      # Tail latency (slowest 1%)
      rand_val > 0.99 ->
        simulate_tail_latency(profile.p99)

      # P95-P99 range (slow requests)
      rand_val > 0.95 ->
        between(profile.p95, profile.p99)

      # P50-P95 range (normal slow)
      rand_val > 0.50 ->
        between(profile.p50, profile.p95)

      # P0-P50 range (fast half)
      true ->
        between(trunc(profile.p50 * 0.5), profile.p50)
    end
  end

  @doc """
  Get latency distribution for a profile (for charting).

  Returns a map with percentile values.
  """
  def distribution(profile_name) do
    profile = Map.fetch!(@latency_profiles, profile_name)

    %{
      p0: trunc(profile.p50 * 0.3),
      p25: trunc(profile.p50 * 0.7),
      p50: profile.p50,
      p75: trunc((profile.p50 + profile.p95) / 2),
      p90: trunc(profile.p95 * 0.9),
      p95: profile.p95,
      p99: profile.p99,
      p100: trunc(profile.p99 * 1.5)
    }
  end

  @doc """
  Simulate a batch of latencies for histogram visualization.

  Returns a list of latency values.
  """
  def simulate_batch(profile_name, count \\ 100) do
    profile = Map.fetch!(@latency_profiles, profile_name)

    1..count
    |> Enum.map(fn _ -> simulate_with_profile(profile) end)
  end

  @doc """
  Calculate percentile from a list of latencies.
  """
  def percentile(latencies, p) when p >= 0 and p <= 1 do
    sorted = Enum.sort(latencies)
    index = trunc(length(sorted) * p)
    Enum.at(sorted, index, 0)
  end

  @doc """
  Analyze latency distribution from a list of values.
  """
  def analyze(latencies) do
    %{
      count: length(latencies),
      mean: mean(latencies),
      median: percentile(latencies, 0.5),
      p50: percentile(latencies, 0.5),
      p95: percentile(latencies, 0.95),
      p99: percentile(latencies, 0.99),
      min: Enum.min(latencies, fn -> 0 end),
      max: Enum.max(latencies, fn -> 0 end)
    }
  end

  # Private helpers

  defp simulate_tail_latency(p99_latency) do
    # Extreme tail: can be 2-5x the P99
    multiplier = 2.0 + :rand.uniform() * 3.0
    trunc(p99_latency * multiplier)
  end

  defp between(min, max) when min < max do
    min + trunc(:rand.uniform() * (max - min))
  end

  defp between(min, _max), do: min

  defp mean([]), do: 0.0

  defp mean(list) do
    sum = Enum.sum(list)
    (sum / length(list)) |> Float.round(2)
  end

  @doc """
  Simulate hedging scenario where a backup request is sent.

  Returns: {primary_latency, hedge_latency, winner}
  """
  def simulate_hedging(profile_name, hedge_delay_ms) do
    profile = Map.fetch!(@latency_profiles, profile_name)

    # Primary request latency
    primary_latency = simulate_with_profile(profile)

    # Hedge fires after delay
    hedge_start = hedge_delay_ms

    # If hedge fires, simulate its latency
    if primary_latency > hedge_start do
      # Hedge request completes independently
      hedge_latency = simulate_with_profile(profile)
      hedge_total = hedge_start + hedge_latency

      # Winner is whoever completes first
      if hedge_total < primary_latency do
        {primary_latency, hedge_total, :hedge_won}
      else
        {primary_latency, hedge_total, :primary_won}
      end
    else
      # Hedge never fired (primary was fast enough)
      {primary_latency, nil, :primary_fast}
    end
  end

  @doc """
  Calculate hedge firing rate for a given delay threshold.
  """
  def hedge_firing_rate(profile_name, hedge_delay_ms, sample_size \\ 1000) do
    profile = Map.fetch!(@latency_profiles, profile_name)

    fired_count =
      1..sample_size
      |> Enum.count(fn _ ->
        latency = simulate_with_profile(profile)
        latency > hedge_delay_ms
      end)

    fired_count / sample_size
  end
end
