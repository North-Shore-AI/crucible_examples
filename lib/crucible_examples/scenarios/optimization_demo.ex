defmodule CrucibleExamples.Scenarios.OptimizationDemo do
  @moduledoc """
  Scenario: Systematic Parameter Search for Prompt Optimization

  Demonstrates automated hyperparameter tuning for LLM prompts:
  - Grid Search: exhaustive parameter space exploration
  - Random Search: efficient random sampling
  - Bayesian Optimization: simplified acquisition-based search

  Parameter Space:
  - temperature: 0.0 to 2.0 (controls randomness)
  - max_tokens: 100 to 2000 (response length)
  - num_examples: 0 to 10 (few-shot examples)

  Objective: maximize accuracy on validation set
  """

  alias CrucibleExamples.Mock.Datasets

  # Validation dataset (separate from training)
  @validation_questions Datasets.math_problems()

  @doc """
  Run parameter optimization using the specified strategy.

  ## Parameters
    - strategy: :grid_search, :random_search, or :bayesian
    - n_trials: number of configurations to evaluate (10, 25, or 50)

  ## Returns
    Map with:
    - trials: list of all trials with configs and scores
    - best_config: optimal configuration found
    - best_score: best validation accuracy achieved
    - convergence_history: best score at each trial
  """
  def optimize_parameters(strategy, n_trials \\ 25) do
    # Generate configurations based on strategy
    configs = generate_configurations(strategy, n_trials)

    # Evaluate each configuration and track progress
    trials =
      configs
      |> Enum.with_index(1)
      |> Enum.map(fn {config, trial_num} ->
        score = evaluate_config(config.temperature, config.max_tokens, config.num_examples)

        %{
          trial_number: trial_num,
          config: config,
          score: score,
          timestamp: DateTime.utc_now()
        }
      end)

    # Find best configuration
    best_trial = Enum.max_by(trials, & &1.score)

    # Build convergence history (best score so far at each trial)
    convergence_history =
      trials
      |> Enum.scan(fn trial, acc ->
        if trial.score > acc.score, do: trial, else: acc
      end)
      |> Enum.map(&%{trial_number: &1.trial_number, best_score: &1.score})

    %{
      strategy: strategy,
      n_trials: n_trials,
      trials: trials,
      best_config: best_trial.config,
      best_score: best_trial.score,
      convergence_history: convergence_history,
      parameter_analysis: analyze_parameters(trials)
    }
  end

  @doc """
  Evaluate a specific configuration on the validation set.

  This is a mock evaluation that returns consistent scores for the same
  configuration (deterministic based on config hash).

  The scoring function models realistic behavior:
  - Temperature 0.5-1.0 tends to perform best
  - More tokens generally better (up to a point)
  - Few-shot examples (3-7) help significantly
  - Too high temperature (>1.5) degrades performance
  - Too many examples (>8) can cause overfitting
  """
  def evaluate_config(temperature, max_tokens, num_examples) do
    # Base score from validation questions
    base_score = 0.65

    # Temperature contribution (optimal around 0.7-0.9)
    temp_score =
      cond do
        temperature < 0.3 -> -0.15
        temperature >= 0.3 and temperature < 0.5 -> -0.05
        temperature >= 0.5 and temperature < 1.0 -> 0.20
        temperature >= 1.0 and temperature < 1.5 -> 0.10
        temperature >= 1.5 -> -0.20
      end

    # Max tokens contribution (diminishing returns after 800)
    token_score =
      cond do
        max_tokens < 200 -> -0.10
        max_tokens >= 200 and max_tokens < 500 -> 0.05
        max_tokens >= 500 and max_tokens < 1000 -> 0.15
        max_tokens >= 1000 -> 0.10
      end

    # Few-shot examples contribution (optimal 3-7)
    examples_score =
      cond do
        num_examples == 0 -> -0.10
        num_examples >= 1 and num_examples <= 2 -> 0.05
        num_examples >= 3 and num_examples <= 7 -> 0.25
        num_examples >= 8 and num_examples <= 10 -> 0.10
        true -> 0.0
      end

    # Interaction penalty (very high temp + many examples = overfitting)
    interaction_penalty =
      if temperature > 1.3 and num_examples > 7 do
        -0.15
      else
        0.0
      end

    # Add deterministic noise based on config hash for consistency
    config_hash = :erlang.phash2({temperature, max_tokens, num_examples})
    noise = rem(config_hash, 100) / 1000.0 - 0.05

    # Calculate final score and clamp to [0, 1]
    final_score =
      base_score + temp_score + token_score + examples_score + interaction_penalty + noise

    final_score |> max(0.0) |> min(1.0) |> Float.round(4)
  end

  @doc """
  Get validation questions for display.
  """
  def validation_questions, do: @validation_questions

  # Private functions

  defp generate_configurations(:grid_search, n_trials) do
    # Grid search: evenly sample the parameter space
    # Adjust grid density based on n_trials
    grid_size =
      case n_trials do
        10 -> {2, 2, 3}
        25 -> {3, 3, 3}
        50 -> {4, 4, 4}
        _ -> {3, 3, 3}
      end

    {temp_steps, token_steps, example_steps} = grid_size

    for temp <- linspace(0.0, 2.0, temp_steps),
        tokens <- linspace(100, 2000, token_steps),
        examples <- 0..example_steps do
      %{
        temperature: Float.round(temp, 2),
        max_tokens: round(tokens),
        num_examples: examples
      }
    end
    |> Enum.take(n_trials)
  end

  defp generate_configurations(:random_search, n_trials) do
    # Random search: uniform random sampling
    1..n_trials
    |> Enum.map(fn _ ->
      %{
        temperature: (:rand.uniform() * 2.0) |> Float.round(2),
        max_tokens: (:rand.uniform() * 1900 + 100) |> round(),
        num_examples: :rand.uniform(11) - 1
      }
    end)
  end

  defp generate_configurations(:bayesian, n_trials) do
    # Simplified Bayesian optimization
    # Start with random exploration, then focus on promising regions

    # First 20% of trials: random exploration
    n_explore = max(div(n_trials, 5), 3)
    exploration_configs = generate_configurations(:random_search, n_explore)

    # Evaluate exploration phase
    exploration_results =
      exploration_configs
      |> Enum.map(fn config ->
        score = evaluate_config(config.temperature, config.max_tokens, config.num_examples)
        {config, score}
      end)

    # Find best region from exploration
    {best_explore_config, _} = Enum.max_by(exploration_results, fn {_, score} -> score end)

    # Remaining trials: exploit around best region with some exploration
    n_exploit = n_trials - n_explore

    exploitation_configs =
      1..n_exploit
      |> Enum.map(fn _ ->
        # Sample near best config with decreasing variance
        %{
          temperature:
            (best_explore_config.temperature + :rand.normal() * 0.3)
            |> max(0.0)
            |> min(2.0)
            |> Float.round(2),
          max_tokens:
            (best_explore_config.max_tokens + :rand.normal() * 300)
            |> max(100)
            |> min(2000)
            |> round(),
          num_examples:
            (best_explore_config.num_examples + round(:rand.normal() * 2))
            |> max(0)
            |> min(10)
        }
      end)

    exploration_configs ++ exploitation_configs
  end

  defp linspace(start, stop, n) when n > 1 do
    step = (stop - start) / (n - 1)
    Enum.map(0..(n - 1), fn i -> start + i * step end)
  end

  defp linspace(start, _stop, 1), do: [start]

  defp analyze_parameters(trials) do
    # Analyze how each parameter correlates with score
    # This helps understand which parameters matter most

    # Group by temperature ranges
    temp_analysis =
      trials
      |> Enum.group_by(fn trial ->
        cond do
          trial.config.temperature < 0.5 -> "0.0-0.5"
          trial.config.temperature < 1.0 -> "0.5-1.0"
          trial.config.temperature < 1.5 -> "1.0-1.5"
          true -> "1.5-2.0"
        end
      end)
      |> Enum.map(fn {range, range_trials} ->
        avg_score =
          range_trials |> Enum.map(& &1.score) |> Enum.sum() |> Kernel./(length(range_trials))

        {range, Float.round(avg_score, 3)}
      end)
      |> Enum.into(%{})

    # Group by token ranges
    token_analysis =
      trials
      |> Enum.group_by(fn trial ->
        cond do
          trial.config.max_tokens < 500 -> "100-500"
          trial.config.max_tokens < 1000 -> "500-1000"
          trial.config.max_tokens < 1500 -> "1000-1500"
          true -> "1500-2000"
        end
      end)
      |> Enum.map(fn {range, range_trials} ->
        avg_score =
          range_trials |> Enum.map(& &1.score) |> Enum.sum() |> Kernel./(length(range_trials))

        {range, Float.round(avg_score, 3)}
      end)
      |> Enum.into(%{})

    # Group by number of examples
    examples_analysis =
      trials
      |> Enum.group_by(fn trial -> "#{trial.config.num_examples}" end)
      |> Enum.map(fn {examples, range_trials} ->
        avg_score =
          range_trials |> Enum.map(& &1.score) |> Enum.sum() |> Kernel./(length(range_trials))

        {examples, Float.round(avg_score, 3)}
      end)
      |> Enum.into(%{})

    %{
      temperature: temp_analysis,
      max_tokens: token_analysis,
      num_examples: examples_analysis
    }
  end
end
