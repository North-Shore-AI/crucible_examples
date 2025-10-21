defmodule CrucibleExamples.Scenarios.StatsDemo do
  @moduledoc """
  Scenario: Statistical Comparison Lab for A/B Testing Models

  Demonstrates proper statistical rigor when comparing two LLM models:
  - Two-sample t-tests for accuracy differences
  - Cohen's d effect size calculation
  - 95% confidence intervals
  - Practical significance thresholds
  - Comprehensive metrics: accuracy, latency, cost

  Shows how to make statistically sound model selection decisions.
  """

  alias CrucibleExamples.Mock.{Models, Datasets}

  @doc """
  Run a statistical comparison between two models.

  Returns detailed results including:
  - Individual model performance (accuracy, latency, cost)
  - Statistical test results (t-test, p-value, effect size)
  - Confidence intervals
  - Winner determination with statistical confidence
  """
  def run_comparison(model_a_id, model_b_id, sample_size, opts \\ []) do
    # Get math problems dataset
    questions = Datasets.batch(:math, sample_size)

    # Run both models on the same questions
    results_a = run_model_on_batch(model_a_id, questions, opts)
    results_b = run_model_on_batch(model_b_id, questions, opts)

    # Calculate statistics
    stats = calculate_statistics(results_a, results_b)

    # Determine winner
    winner = determine_winner(model_a_id, model_b_id, stats)

    # Build comprehensive result
    %{
      model_a: %{
        id: model_a_id,
        name: Models.get_model(model_a_id).name,
        results: results_a,
        metrics: calculate_metrics(results_a)
      },
      model_b: %{
        id: model_b_id,
        name: Models.get_model(model_b_id).name,
        results: results_b,
        metrics: calculate_metrics(results_b)
      },
      statistics: stats,
      winner: winner,
      sample_size: sample_size,
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Calculate comprehensive statistics comparing two sets of results.

  Returns:
  - accuracy: t-test, p-value, effect size, confidence intervals
  - latency: comparison statistics
  - cost: comparison statistics
  """
  def calculate_statistics(results_a, results_b) do
    # Extract accuracy data
    accuracies_a = Enum.map(results_a, fn r -> if r.correct, do: 1.0, else: 0.0 end)
    accuracies_b = Enum.map(results_b, fn r -> if r.correct, do: 1.0, else: 0.0 end)

    # Extract latency data
    latencies_a = Enum.map(results_a, & &1.latency_ms)
    latencies_b = Enum.map(results_b, & &1.latency_ms)

    # Extract cost data
    costs_a = Enum.map(results_a, & &1.cost_usd)
    costs_b = Enum.map(results_b, & &1.cost_usd)

    %{
      accuracy: compare_metric(accuracies_a, accuracies_b, "Accuracy"),
      latency: compare_metric(latencies_a, latencies_b, "Latency (ms)"),
      cost: compare_metric(costs_a, costs_b, "Cost ($)")
    }
  end

  # Private functions

  defp run_model_on_batch(model_id, questions, opts) do
    questions
    |> Enum.map(fn question ->
      result = Models.query(model_id, question.question, question.correct_answer, opts)

      case result do
        {:ok, response} ->
          %{
            question_id: question.id,
            correct: response.answer == question.correct_answer,
            latency_ms: response.latency_ms,
            cost_usd: response.cost_usd,
            confidence: response.confidence,
            answer: response.answer,
            correct_answer: question.correct_answer
          }

        {:error, _error} ->
          %{
            question_id: question.id,
            correct: false,
            latency_ms: 0,
            cost_usd: 0,
            confidence: 0.0,
            answer: "ERROR",
            correct_answer: question.correct_answer
          }
      end
    end)
  end

  defp calculate_metrics(results) do
    total = length(results)
    correct_count = Enum.count(results, & &1.correct)

    latencies = Enum.map(results, & &1.latency_ms)
    costs = Enum.map(results, & &1.cost_usd)

    %{
      accuracy: correct_count / total,
      total_questions: total,
      correct_count: correct_count,
      latency_mean: mean(latencies),
      latency_p50: percentile(latencies, 50),
      latency_p95: percentile(latencies, 95),
      latency_p99: percentile(latencies, 99),
      cost_per_query: mean(costs),
      total_cost: Enum.sum(costs)
    }
  end

  defp compare_metric(values_a, values_b, metric_name) do
    n_a = length(values_a)
    n_b = length(values_b)

    mean_a = mean(values_a)
    mean_b = mean(values_b)

    std_a = standard_deviation(values_a)
    std_b = standard_deviation(values_b)

    # Calculate pooled standard error
    pooled_se = pooled_standard_error(std_a, std_b, n_a, n_b)

    # Calculate t-statistic
    t_stat = if pooled_se > 0, do: (mean_a - mean_b) / pooled_se, else: 0.0

    # Degrees of freedom (simplified Welch's approximation)
    df = n_a + n_b - 2

    # Approximate p-value (two-tailed)
    p_value = approximate_p_value(abs(t_stat), df)

    # Cohen's d effect size
    pooled_std = pooled_standard_deviation(std_a, std_b, n_a, n_b)
    cohens_d = if pooled_std > 0, do: (mean_a - mean_b) / pooled_std, else: 0.0

    # 95% Confidence intervals
    # Critical value for 95% CI (approximation: 1.96 for large samples, 2.0 for small)
    critical_value = if df > 30, do: 1.96, else: 2.0

    ci_a = confidence_interval(mean_a, std_a, n_a, critical_value)
    ci_b = confidence_interval(mean_b, std_b, n_b, critical_value)
    ci_diff = confidence_interval_difference(mean_a, mean_b, pooled_se, critical_value)

    # Interpret results
    significance = interpret_significance(p_value)
    effect_size_interpretation = interpret_effect_size(cohens_d)

    %{
      metric_name: metric_name,
      model_a: %{
        mean: Float.round(mean_a, 4),
        std: Float.round(std_a, 4),
        ci_lower: Float.round(ci_a.lower, 4),
        ci_upper: Float.round(ci_a.upper, 4),
        n: n_a
      },
      model_b: %{
        mean: Float.round(mean_b, 4),
        std: Float.round(std_b, 4),
        ci_lower: Float.round(ci_b.lower, 4),
        ci_upper: Float.round(ci_b.upper, 4),
        n: n_b
      },
      difference: %{
        value: Float.round(mean_a - mean_b, 4),
        ci_lower: Float.round(ci_diff.lower, 4),
        ci_upper: Float.round(ci_diff.upper, 4)
      },
      t_statistic: Float.round(t_stat, 4),
      p_value: Float.round(p_value, 4),
      degrees_of_freedom: df,
      cohens_d: Float.round(cohens_d, 4),
      significance: significance,
      effect_size_interpretation: effect_size_interpretation,
      statistically_significant: p_value < 0.05,
      practically_significant: abs(cohens_d) > 0.2
    }
  end

  defp determine_winner(model_a_id, model_b_id, stats) do
    accuracy_stats = stats.accuracy
    latency_stats = stats.latency
    cost_stats = stats.cost

    model_a_name = Models.get_model(model_a_id).name
    model_b_name = Models.get_model(model_b_id).name

    # Determine accuracy winner
    accuracy_winner =
      cond do
        !accuracy_stats.statistically_significant ->
          "No significant difference"

        accuracy_stats.difference.value > 0 ->
          model_a_name

        true ->
          model_b_name
      end

    # Determine latency winner (lower is better)
    latency_winner =
      cond do
        !latency_stats.statistically_significant ->
          "No significant difference"

        latency_stats.difference.value < 0 ->
          model_a_name

        true ->
          model_b_name
      end

    # Determine cost winner (lower is better)
    cost_winner =
      cond do
        !cost_stats.statistically_significant ->
          "No significant difference"

        cost_stats.difference.value < 0 ->
          model_a_name

        true ->
          model_b_name
      end

    # Overall recommendation
    overall_recommendation =
      make_overall_recommendation(
        accuracy_stats,
        latency_stats,
        cost_stats,
        model_a_name,
        model_b_name
      )

    %{
      accuracy_winner: accuracy_winner,
      latency_winner: latency_winner,
      cost_winner: cost_winner,
      overall_recommendation: overall_recommendation
    }
  end

  defp make_overall_recommendation(
         accuracy_stats,
         latency_stats,
         cost_stats,
         model_a_name,
         model_b_name
       ) do
    # Score each model (higher is better)
    score_a = 0
    score_b = 0

    # Accuracy is most important
    {score_a, score_b} =
      if accuracy_stats.statistically_significant do
        if accuracy_stats.difference.value > 0 do
          {score_a + 3, score_b}
        else
          {score_a, score_b + 3}
        end
      else
        {score_a, score_b}
      end

    # Latency matters but less than accuracy
    {score_a, score_b} =
      if latency_stats.statistically_significant do
        if latency_stats.difference.value < 0 do
          {score_a + 2, score_b}
        else
          {score_a, score_b + 2}
        end
      else
        {score_a, score_b}
      end

    # Cost matters least
    {score_a, score_b} =
      if cost_stats.statistically_significant do
        if cost_stats.difference.value < 0 do
          {score_a + 1, score_b}
        else
          {score_a, score_b + 1}
        end
      else
        {score_a, score_b}
      end

    cond do
      score_a > score_b ->
        "#{model_a_name} is recommended (better overall performance)"

      score_b > score_a ->
        "#{model_b_name} is recommended (better overall performance)"

      true ->
        "No clear winner - models perform similarly across metrics"
    end
  end

  # Statistical helper functions

  defp mean(values) when length(values) == 0, do: 0.0

  defp mean(values) do
    Enum.sum(values) / length(values)
  end

  defp variance(values) do
    n = length(values)
    if n <= 1, do: 0.0, else: do_variance(values, n)
  end

  defp do_variance(values, n) do
    mean_val = mean(values)

    sum_squared_diff =
      values
      |> Enum.map(fn x -> :math.pow(x - mean_val, 2) end)
      |> Enum.sum()

    sum_squared_diff / (n - 1)
  end

  defp standard_deviation(values) do
    :math.sqrt(variance(values))
  end

  defp pooled_standard_error(std_a, std_b, n_a, n_b) do
    var_a = :math.pow(std_a, 2) / n_a
    var_b = :math.pow(std_b, 2) / n_b
    :math.sqrt(var_a + var_b)
  end

  defp pooled_standard_deviation(std_a, std_b, n_a, n_b) do
    var_a = :math.pow(std_a, 2)
    var_b = :math.pow(std_b, 2)

    pooled_var = ((n_a - 1) * var_a + (n_b - 1) * var_b) / (n_a + n_b - 2)
    :math.sqrt(pooled_var)
  end

  defp confidence_interval(mean_val, std, n, critical_value) do
    margin = critical_value * (std / :math.sqrt(n))

    %{
      lower: mean_val - margin,
      upper: mean_val + margin
    }
  end

  defp confidence_interval_difference(mean_a, mean_b, pooled_se, critical_value) do
    diff = mean_a - mean_b
    margin = critical_value * pooled_se

    %{
      lower: diff - margin,
      upper: diff + margin
    }
  end

  defp percentile(values, _p) when length(values) == 0, do: 0.0

  defp percentile(values, p) do
    sorted = Enum.sort(values)
    n = length(sorted)
    rank = p / 100.0 * (n - 1)
    lower_index = floor(rank)
    upper_index = ceil(rank)

    if lower_index == upper_index do
      Enum.at(sorted, lower_index)
    else
      lower_value = Enum.at(sorted, lower_index)
      upper_value = Enum.at(sorted, upper_index)
      fraction = rank - lower_index
      lower_value + fraction * (upper_value - lower_value)
    end
  end

  defp approximate_p_value(t_abs, df) do
    # Very simplified p-value approximation
    # For a more accurate implementation, you'd use a proper t-distribution CDF
    # This approximation works reasonably well for df > 10

    cond do
      df > 30 ->
        # Use normal approximation
        approximate_p_value_normal(t_abs)

      true ->
        # Conservative approximation for smaller samples
        approximate_p_value_t(t_abs, df)
    end
  end

  defp approximate_p_value_normal(z) do
    # Approximate using standard normal distribution
    # This is a simplified approximation
    cond do
      z > 3.5 -> 0.0005
      z > 3.0 -> 0.003
      z > 2.58 -> 0.01
      z > 2.33 -> 0.02
      z > 1.96 -> 0.05
      z > 1.65 -> 0.10
      z > 1.28 -> 0.20
      true -> 0.50
    end
    |> Kernel.*(2.0)

    # Two-tailed
  end

  defp approximate_p_value_t(t_abs, df) do
    # Conservative t-distribution approximation
    # Critical values are higher for smaller df
    adjustment = :math.sqrt(30.0 / max(df, 5))
    adjusted_t = t_abs / adjustment
    approximate_p_value_normal(adjusted_t)
  end

  defp interpret_significance(p_value) do
    cond do
      p_value < 0.001 -> "Highly significant (p < 0.001)"
      p_value < 0.01 -> "Very significant (p < 0.01)"
      p_value < 0.05 -> "Significant (p < 0.05)"
      p_value < 0.10 -> "Marginally significant (p < 0.10)"
      true -> "Not significant (p >= 0.10)"
    end
  end

  defp interpret_effect_size(cohens_d) do
    d_abs = abs(cohens_d)

    cond do
      d_abs < 0.2 -> "Negligible effect"
      d_abs < 0.5 -> "Small effect"
      d_abs < 0.8 -> "Medium effect"
      true -> "Large effect"
    end
  end
end
