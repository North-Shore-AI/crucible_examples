#!/usr/bin/env elixir

# Request Hedging Demo
# Demonstrates how backup requests reduce tail latency

IO.puts("\n=== Request Hedging Demo ===\n")

alias CrucibleExamples.Mock.Latency

# Configuration
profile = :medium
hedge_delay = 1000
num_samples = 100

IO.puts("Configuration:")
IO.puts("  Latency Profile: #{profile}")
IO.puts("  Hedge Delay: #{hedge_delay}ms")
IO.puts("  Sample Size: #{num_samples}")
IO.puts("")

# Baseline: No hedging
IO.puts("--- Baseline (No Hedging) ---")
baseline_latencies = Latency.simulate_batch(profile, num_samples)
baseline_stats = Latency.analyze(baseline_latencies)

IO.puts("P50: #{baseline_stats.p50}ms")
IO.puts("P95: #{baseline_stats.p95}ms")
IO.puts("P99: #{baseline_stats.p99}ms")
IO.puts("Mean: #{baseline_stats.mean}ms")
IO.puts("")

# With hedging
IO.puts("--- With Hedging ---")

hedged_results =
  for _ <- 1..num_samples do
    {primary, hedge, winner} = Latency.simulate_hedging(profile, hedge_delay)

    final_latency =
      case winner do
        :primary_fast -> primary
        :primary_won -> primary
        :hedge_won -> hedge
      end

    {final_latency, winner}
  end

hedged_latencies = Enum.map(hedged_results, fn {lat, _} -> lat end)
hedged_stats = Latency.analyze(hedged_latencies)

IO.puts("P50: #{hedged_stats.p50}ms")
IO.puts("P95: #{hedged_stats.p95}ms")
IO.puts("P99: #{hedged_stats.p99}ms")
IO.puts("Mean: #{hedged_stats.mean}ms")
IO.puts("")

# Hedge firing statistics
firing_counts =
  hedged_results
  |> Enum.frequencies_by(fn {_, winner} -> winner end)

IO.puts("--- Hedge Statistics ---")
IO.puts("Primary Fast (hedge never fired): #{Map.get(firing_counts, :primary_fast, 0)}")
IO.puts("Primary Won (hedge fired but lost): #{Map.get(firing_counts, :primary_won, 0)}")
IO.puts("Hedge Won (hedge fired and won): #{Map.get(firing_counts, :hedge_won, 0)}")

total_hedges = Map.get(firing_counts, :primary_won, 0) + Map.get(firing_counts, :hedge_won, 0)
firing_rate = total_hedges / num_samples * 100
IO.puts("Hedge Firing Rate: #{Float.round(firing_rate, 1)}%")
IO.puts("")

# Improvement
IO.puts("--- Latency Improvement ---")
p99_improvement = (baseline_stats.p99 - hedged_stats.p99) / baseline_stats.p99 * 100
p95_improvement = (baseline_stats.p95 - hedged_stats.p95) / baseline_stats.p95 * 100

IO.puts("P99 Improvement: #{Float.round(p99_improvement, 1)}%")
IO.puts("P95 Improvement: #{Float.round(p95_improvement, 1)}%")
IO.puts("")

# Cost analysis (assuming each request costs $0.005)
cost_per_query = 0.005
baseline_cost = cost_per_query * num_samples
hedged_cost = cost_per_query * num_samples * (1 + firing_rate / 100)

IO.puts("--- Cost Analysis ---")
IO.puts("Baseline Cost: $#{Float.round(baseline_cost, 4)}")
IO.puts("Hedged Cost: $#{Float.round(hedged_cost, 4)}")
IO.puts("Cost Overhead: #{Float.round(hedged_cost / baseline_cost - 1, 2) * 100}%")
IO.puts("")
