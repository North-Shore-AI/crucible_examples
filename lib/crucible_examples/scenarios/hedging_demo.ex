defmodule CrucibleExamples.Scenarios.HedgingDemo do
  @moduledoc """
  Scenario: Customer Support Chatbot with Request Hedging

  Demonstrates how request hedging reduces tail latency (P95/P99) by
  sending backup requests after a threshold delay.

  Shows:
  - Fixed delay hedging (e.g., fire after 1000ms)
  - Percentile-based hedging (fire at P95 of baseline)
  - Adaptive hedging (simplified ML-based)
  - Hedge firing rate and cost overhead
  - P50/P95/P99 improvement metrics
  """

  alias CrucibleExamples.Mock.Latency

  @doc """
  Run a single hedged request.

  Returns:
    %{
      query_id: integer,
      query: string,
      strategy: atom,
      primary_latency: integer (ms),
      hedge_latency: integer | nil (ms),
      winner: :primary | :hedge | :primary_fast,
      total_latency: integer (ms),
      hedge_fired: boolean,
      cost_multiplier: float (1.0 or 2.0),
      delay_threshold: integer (ms)
    }
  """
  def run_hedging(query_id, strategy, opts \\ []) do
    query = get_query(query_id)
    profile = Keyword.get(opts, :latency_profile, :medium)

    # Calculate delay threshold based on strategy
    delay_threshold = calculate_delay_threshold(strategy, profile, opts)

    # Simulate the hedged request
    {primary_latency, hedge_latency, winner} =
      Latency.simulate_hedging(profile, delay_threshold)

    # Determine if hedge fired
    hedge_fired = hedge_latency != nil

    # Calculate actual latency seen by user (min of primary or hedge)
    total_latency =
      if hedge_fired do
        min(primary_latency, hedge_latency)
      else
        primary_latency
      end

    # Cost is 2x if hedge fired, 1x otherwise
    cost_multiplier = if hedge_fired, do: 2.0, else: 1.0

    %{
      query_id: query_id,
      query: query.text,
      category: query.category,
      strategy: strategy,
      primary_latency: primary_latency,
      hedge_latency: hedge_latency,
      winner: winner,
      total_latency: total_latency,
      hedge_fired: hedge_fired,
      cost_multiplier: cost_multiplier,
      delay_threshold: delay_threshold,
      latency_saved: if(hedge_fired, do: primary_latency - total_latency, else: 0),
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Run a batch of hedged requests to show statistical improvement.

  Returns aggregated metrics showing P50/P95/P99 before and after hedging.
  """
  def run_batch(count, strategy, opts \\ []) do
    profile = Keyword.get(opts, :latency_profile, :medium)
    delay_threshold = calculate_delay_threshold(strategy, profile, opts)

    # Run baseline (no hedging) for comparison
    baseline_latencies = Latency.simulate_batch(profile, count)

    # Run hedged requests
    hedged_results =
      1..count
      |> Enum.map(fn i ->
        query_id = rem(i - 1, 5) + 1
        run_hedging(query_id, strategy, opts)
      end)

    # Extract hedged latencies
    hedged_latencies = Enum.map(hedged_results, & &1.total_latency)

    # Calculate metrics
    baseline_metrics = Latency.analyze(baseline_latencies)
    hedged_metrics = Latency.analyze(hedged_latencies)

    # Calculate hedge firing rate
    hedge_fired_count = Enum.count(hedged_results, & &1.hedge_fired)
    hedge_firing_rate = hedge_fired_count / count

    # Calculate average cost multiplier
    avg_cost_multiplier =
      hedged_results
      |> Enum.map(& &1.cost_multiplier)
      |> Enum.sum()
      |> Kernel./(count)
      |> Float.round(2)

    # Calculate latency improvements
    p50_improvement_pct =
      ((baseline_metrics.p50 - hedged_metrics.p50) / baseline_metrics.p50 * 100)
      |> Float.round(1)

    p95_improvement_pct =
      ((baseline_metrics.p95 - hedged_metrics.p95) / baseline_metrics.p95 * 100)
      |> Float.round(1)

    p99_improvement_pct =
      ((baseline_metrics.p99 - hedged_metrics.p99) / baseline_metrics.p99 * 100)
      |> Float.round(1)

    %{
      count: count,
      strategy: strategy,
      delay_threshold: delay_threshold,
      baseline: baseline_metrics,
      hedged: hedged_metrics,
      improvement: %{
        p50_ms: baseline_metrics.p50 - hedged_metrics.p50,
        p95_ms: baseline_metrics.p95 - hedged_metrics.p95,
        p99_ms: baseline_metrics.p99 - hedged_metrics.p99,
        p50_pct: p50_improvement_pct,
        p95_pct: p95_improvement_pct,
        p99_pct: p99_improvement_pct
      },
      hedge_stats: %{
        firing_rate: Float.round(hedge_firing_rate, 3),
        fired_count: hedge_fired_count,
        avg_cost_multiplier: avg_cost_multiplier
      },
      results: hedged_results,
      baseline_latencies: baseline_latencies,
      hedged_latencies: hedged_latencies
    }
  end

  @doc """
  Compare baseline (no hedging) vs hedged performance.

  Shows the dramatic reduction in tail latency with hedging.
  """
  def compare_baseline_vs_hedged(count, opts \\ []) do
    profile = Keyword.get(opts, :latency_profile, :medium)

    # Test multiple strategies
    strategies = [:fixed, :percentile, :adaptive]

    results =
      strategies
      |> Enum.map(fn strategy ->
        batch_result = run_batch(count, strategy, opts)

        %{
          strategy: strategy,
          delay_threshold: batch_result.delay_threshold,
          baseline: batch_result.baseline,
          hedged: batch_result.hedged,
          improvement: batch_result.improvement,
          hedge_stats: batch_result.hedge_stats
        }
      end)

    # Find best strategy (highest P99 improvement)
    best_strategy =
      results
      |> Enum.max_by(fn result -> result.improvement.p99_pct end)

    %{
      count: count,
      profile: profile,
      strategies: results,
      best_strategy: best_strategy.strategy,
      best_p99_improvement: best_strategy.improvement.p99_pct
    }
  end

  # Private functions

  @doc """
  Calculate the delay threshold for hedging based on strategy.
  """
  def calculate_delay_threshold(strategy, profile, opts) do
    case strategy do
      :fixed ->
        # Fixed delay (e.g., 1000ms)
        Keyword.get(opts, :fixed_delay_ms, 1000)

      :percentile ->
        # Fire at P95 of baseline distribution
        distribution = Latency.distribution(profile)
        distribution.p95

      :adaptive ->
        # Simplified adaptive: fire at P75 (earlier than percentile)
        # In production, this would use ML to predict optimal threshold
        distribution = Latency.distribution(profile)
        distribution.p75
    end
  end

  # Sample customer support queries
  defp get_query(query_id) do
    queries = [
      %{
        id: 1,
        category: :order_status,
        text: "Where is my order #12345?",
        expected_latency: :fast
      },
      %{
        id: 2,
        category: :refund,
        text: "I need a refund for order #67890",
        expected_latency: :medium
      },
      %{
        id: 3,
        category: :technical_support,
        text: "My account login isn't working",
        expected_latency: :slow
      },
      %{
        id: 4,
        category: :product_question,
        text: "Does this product work with iOS 18?",
        expected_latency: :fast
      },
      %{
        id: 5,
        category: :complaint,
        text: "I received the wrong item and need to speak to a manager",
        expected_latency: :medium
      }
    ]

    Enum.find(queries, fn q -> q.id == query_id end)
  end

  @doc """
  Get all available queries for selection UI.
  """
  def queries do
    1..5
    |> Enum.map(&get_query/1)
  end

  @doc """
  Get latency profile distribution for visualization.
  """
  def get_latency_distribution(profile \\ :medium) do
    Latency.distribution(profile)
  end

  @doc """
  Calculate histogram buckets from latency values.
  """
  def calculate_histogram(latencies, bucket_count \\ 20) do
    if Enum.empty?(latencies) do
      []
    else
      min_val = Enum.min(latencies)
      max_val = Enum.max(latencies)
      bucket_size = max(1, div(max_val - min_val, bucket_count))

      # Create buckets
      buckets =
        0..(bucket_count - 1)
        |> Enum.map(fn i ->
          bucket_start = min_val + i * bucket_size
          bucket_end = bucket_start + bucket_size

          count =
            Enum.count(latencies, fn lat ->
              lat >= bucket_start and lat < bucket_end
            end)

          %{
            start: bucket_start,
            end: bucket_end,
            count: count,
            label: "#{bucket_start}-#{bucket_end}ms"
          }
        end)

      # Add any stragglers to the last bucket
      last_bucket = List.last(buckets)

      stragglers =
        Enum.count(latencies, fn lat ->
          lat >= last_bucket.end
        end)

      if stragglers > 0 do
        List.update_at(buckets, -1, fn bucket ->
          %{bucket | count: bucket.count + stragglers}
        end)
      else
        buckets
      end
    end
  end
end
