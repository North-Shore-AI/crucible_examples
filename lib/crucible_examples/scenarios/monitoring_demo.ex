defmodule CrucibleExamples.Scenarios.MonitoringDemo do
  @moduledoc """
  Scenario: Production Model Health Monitoring with Degradation Detection

  Demonstrates continuous monitoring of a production model with statistical
  degradation detection. Shows when model performance degrades enough to
  trigger retraining alerts.

  Shows:
  - 30-day historical baseline with natural variation
  - Real-time metrics tracking (accuracy, latency, error rate)
  - Statistical degradation detection using z-tests
  - Confidence intervals and alert thresholds
  - Retraining trigger logic
  """

  @doc """
  Generate mock baseline data for the past N days.

  Returns a list of daily metrics with realistic variation around baseline values:
  - Accuracy: ~92% ± 2%
  - Latency P95: ~500ms ± 100ms
  - Error Rate: ~3% ± 1.5%

  ## Examples

      iex> baseline = generate_baseline_data(30)
      iex> length(baseline)
      30
  """
  def generate_baseline_data(days \\ 30) do
    # Use consistent seed for reproducible results
    :rand.seed(:exsplus, {1, 2, 3})

    today = Date.utc_today()

    Enum.map((days - 1)..0, fn days_ago ->
      date = Date.add(today, -days_ago)

      %{
        date: date,
        accuracy: random_around(0.92, 0.02),
        latency_p95: random_around(500, 100) |> round(),
        error_rate: random_around(0.03, 0.015),
        predictions_count: Enum.random(8000..12000),
        timestamp: DateTime.new!(date, ~T[12:00:00], "Etc/UTC")
      }
    end)
  end

  @doc """
  Simulate current day performance.

  When degraded=true, simulates performance degradation:
  - Accuracy drops to ~89% (3% decrease)
  - Latency increases to ~650ms (30% increase)
  - Error rate increases to ~5% (67% increase)

  ## Examples

      iex> current = simulate_current_day(false)
      iex> current.accuracy > 0.90
      true

      iex> degraded = simulate_current_day(true)
      iex> degraded.accuracy < 0.90
      true
  """
  def simulate_current_day(degraded \\ false) do
    # Use different seed for current day to show variation
    :rand.seed(:exsplus, {4, 5, 6})

    today = Date.utc_today()

    if degraded do
      %{
        date: today,
        accuracy: random_around(0.89, 0.01),
        latency_p95: random_around(650, 80) |> round(),
        error_rate: random_around(0.05, 0.01),
        predictions_count: Enum.random(8000..12000),
        timestamp: DateTime.utc_now()
      }
    else
      %{
        date: today,
        accuracy: random_around(0.92, 0.02),
        latency_p95: random_around(500, 100) |> round(),
        error_rate: random_around(0.03, 0.015),
        predictions_count: Enum.random(8000..12000),
        timestamp: DateTime.utc_now()
      }
    end
  end

  @doc """
  Detect degradation by comparing current metrics to baseline statistics.

  Uses statistical tests (z-score) to determine if current performance
  is significantly worse than baseline. Returns detailed analysis including:
  - Baseline statistics (mean, standard deviation)
  - Current vs baseline comparison
  - Z-scores for each metric
  - Alert status and severity
  - Retraining recommendation

  Alert thresholds:
  - Warning: z-score > 1.5 (90% confidence)
  - Critical: z-score > 2.0 (95% confidence)

  ## Examples

      iex> baseline = generate_baseline_data(30)
      iex> current = simulate_current_day(false)
      iex> result = detect_degradation(baseline, current)
      iex> result.needs_retraining
      false
  """
  def detect_degradation(baseline, current) do
    # Calculate baseline statistics
    baseline_stats = calculate_baseline_stats(baseline)

    # Calculate z-scores for each metric
    accuracy_z =
      calculate_z_score(
        current.accuracy,
        baseline_stats.accuracy.mean,
        baseline_stats.accuracy.std_dev,
        :lower_is_worse
      )

    latency_z =
      calculate_z_score(
        current.latency_p95,
        baseline_stats.latency_p95.mean,
        baseline_stats.latency_p95.std_dev,
        :higher_is_worse
      )

    error_rate_z =
      calculate_z_score(
        current.error_rate,
        baseline_stats.error_rate.mean,
        baseline_stats.error_rate.std_dev,
        :higher_is_worse
      )

    # Determine alert severity
    max_z = Enum.max([abs(accuracy_z), abs(latency_z), abs(error_rate_z)])

    alert_status =
      cond do
        max_z > 2.0 -> :critical
        max_z > 1.5 -> :warning
        true -> :normal
      end

    # Check individual metric degradation
    accuracy_degraded = accuracy_z < -2.0
    latency_degraded = latency_z > 2.0
    error_rate_degraded = error_rate_z > 2.0

    # Recommend retraining if any critical degradation detected
    needs_retraining = accuracy_degraded or latency_degraded or error_rate_degraded

    # Calculate percentage changes
    accuracy_change =
      (current.accuracy - baseline_stats.accuracy.mean) / baseline_stats.accuracy.mean * 100

    latency_change =
      (current.latency_p95 - baseline_stats.latency_p95.mean) / baseline_stats.latency_p95.mean *
        100

    error_rate_change =
      (current.error_rate - baseline_stats.error_rate.mean) / baseline_stats.error_rate.mean * 100

    %{
      baseline_stats: baseline_stats,
      current_metrics: current,
      z_scores: %{
        accuracy: Float.round(accuracy_z, 2),
        latency_p95: Float.round(latency_z, 2),
        error_rate: Float.round(error_rate_z, 2)
      },
      percentage_changes: %{
        accuracy: Float.round(accuracy_change, 2),
        latency_p95: Float.round(latency_change, 2),
        error_rate: Float.round(error_rate_change, 2)
      },
      degradation_detected: %{
        accuracy: accuracy_degraded,
        latency_p95: latency_degraded,
        error_rate: error_rate_degraded
      },
      alert_status: alert_status,
      needs_retraining: needs_retraining,
      alert_message:
        build_alert_message(
          alert_status,
          accuracy_degraded,
          latency_degraded,
          error_rate_degraded
        )
    }
  end

  @doc """
  Get full monitoring data for a time window.

  Time windows:
  - :day_24h - Last 24 hours (hourly data)
  - :days_7 - Last 7 days (daily data)
  - :days_30 - Last 30 days (daily data)
  """
  def get_monitoring_data(time_window, degraded \\ false) do
    {days, label} =
      case time_window do
        :day_24h -> {1, "24 Hours"}
        :days_7 -> {7, "7 Days"}
        :days_30 -> {30, "30 Days"}
      end

    baseline = generate_baseline_data(days)
    current = simulate_current_day(degraded)
    analysis = detect_degradation(baseline, current)

    %{
      time_window: time_window,
      time_window_label: label,
      baseline_data: baseline,
      current_data: current,
      analysis: analysis,
      generated_at: DateTime.utc_now()
    }
  end

  # Private functions

  defp calculate_baseline_stats(baseline) do
    accuracies = Enum.map(baseline, & &1.accuracy)
    latencies = Enum.map(baseline, & &1.latency_p95)
    error_rates = Enum.map(baseline, & &1.error_rate)

    %{
      accuracy: calculate_stats(accuracies),
      latency_p95: calculate_stats(latencies),
      error_rate: calculate_stats(error_rates),
      sample_size: length(baseline)
    }
  end

  defp calculate_stats(values) do
    mean = Enum.sum(values) / length(values)

    variance =
      Enum.reduce(values, 0, fn x, acc -> acc + :math.pow(x - mean, 2) end) / length(values)

    std_dev = :math.sqrt(variance)

    # 95% confidence interval (±2 standard deviations)
    ci_lower = mean - 2 * std_dev
    ci_upper = mean + 2 * std_dev

    %{
      mean: mean,
      std_dev: std_dev,
      min: Enum.min(values),
      max: Enum.max(values),
      confidence_interval: %{
        lower: ci_lower,
        upper: ci_upper,
        confidence_level: 0.95
      }
    }
  end

  defp calculate_z_score(current_value, baseline_mean, baseline_std_dev, direction) do
    # Calculate standard z-score
    z = (current_value - baseline_mean) / baseline_std_dev

    # Adjust sign based on whether higher or lower is worse
    case direction do
      # Negative z means worse (below baseline)
      :lower_is_worse -> z
      # Positive z means worse (above baseline)
      :higher_is_worse -> z
    end
  end

  defp build_alert_message(:normal, _, _, _) do
    "All metrics within normal range. Model performance is stable."
  end

  defp build_alert_message(:warning, accuracy_deg, latency_deg, error_deg) do
    issues = []
    issues = if accuracy_deg, do: ["accuracy below threshold" | issues], else: issues
    issues = if latency_deg, do: ["latency above threshold" | issues], else: issues
    issues = if error_deg, do: ["error rate elevated" | issues], else: issues

    if length(issues) > 0 do
      "Warning: Detected " <> Enum.join(issues, ", ") <> ". Monitor closely."
    else
      "Warning: Metrics showing unusual variation. Monitor closely."
    end
  end

  defp build_alert_message(:critical, accuracy_deg, latency_deg, error_deg) do
    issues = []
    issues = if accuracy_deg, do: ["accuracy degradation" | issues], else: issues
    issues = if latency_deg, do: ["latency degradation" | issues], else: issues
    issues = if error_deg, do: ["error rate spike" | issues], else: issues

    if length(issues) > 0 do
      "CRITICAL: " <> Enum.join(issues, ", ") <> " detected. Retraining recommended."
    else
      "CRITICAL: Significant performance degradation detected. Retraining recommended."
    end
  end

  # Generate random value around a center with given standard deviation
  defp random_around(center, std_dev) do
    # Box-Muller transform for normal distribution
    u1 = :rand.uniform()
    u2 = :rand.uniform()
    z = :math.sqrt(-2 * :math.log(u1)) * :math.cos(2 * :math.pi() * u2)

    center + z * std_dev
  end
end
