#!/usr/bin/env elixir

# Latency Simulation Demo
# Demonstrates realistic latency distributions

IO.puts("\n=== Latency Simulation Demo ===\n")

alias CrucibleExamples.Mock.Latency

# Show distribution for each profile
for profile <- [:fast, :medium, :slow] do
  IO.puts("#{String.upcase(to_string(profile))} Profile:")

  dist = Latency.distribution(profile)
  IO.puts("  P0:  #{dist.p0}ms")
  IO.puts("  P50: #{dist.p50}ms")
  IO.puts("  P95: #{dist.p95}ms")
  IO.puts("  P99: #{dist.p99}ms")
  IO.puts("  P100: #{dist.p100}ms")
  IO.puts("")
end

# Simulate a batch and analyze
IO.puts("--- Batch Simulation (Medium Profile, 1000 samples) ---")
samples = Latency.simulate_batch(:medium, 1000)
stats = Latency.analyze(samples)

IO.puts("Count: #{stats.count}")
IO.puts("Mean: #{stats.mean}ms")
IO.puts("Median: #{stats.median}ms")
IO.puts("P95: #{stats.p95}ms")
IO.puts("P99: #{stats.p99}ms")
IO.puts("Min: #{stats.min}ms")
IO.puts("Max: #{stats.max}ms")
IO.puts("")

# Demonstrate hedging simulation
IO.puts("--- Hedging Simulation ---")
IO.puts("Running 10 hedging scenarios with 1000ms delay threshold:\n")

for i <- 1..10 do
  {primary, hedge, winner} = Latency.simulate_hedging(:medium, 1000)

  outcome =
    case winner do
      :primary_fast -> "Primary was fast (#{primary}ms, hedge never fired)"
      :primary_won -> "Primary won (#{primary}ms vs hedge #{hedge}ms)"
      :hedge_won -> "Hedge won (#{hedge}ms vs primary #{primary}ms)"
    end

  IO.puts("#{i}. #{outcome}")
end

IO.puts("")

# Calculate hedge firing rate
IO.puts("--- Hedge Firing Rate Analysis ---")

for delay <- [500, 1000, 2000] do
  rate = Latency.hedge_firing_rate(:medium, delay, 1000)
  IO.puts("Delay #{delay}ms: #{Float.round(rate * 100, 1)}% firing rate")
end

IO.puts("")
