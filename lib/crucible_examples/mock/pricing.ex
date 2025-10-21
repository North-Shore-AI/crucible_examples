defmodule CrucibleExamples.Mock.Pricing do
  @moduledoc """
  Cost tracking for mock LLM models.

  Tracks per-query costs and aggregates spending across experiments.
  """

  @doc """
  Calculate total cost for a set of model responses.
  """
  def calculate_total_cost(responses) when is_map(responses) do
    responses
    |> Map.values()
    |> Enum.reduce(0.0, fn
      {:ok, response}, acc -> acc + response.cost_usd
      {:error, _}, acc -> acc
    end)
    |> Float.round(6)
  end

  @doc """
  Calculate cost for ensemble queries.

  An ensemble query runs multiple models, so cost is additive.
  """
  def ensemble_cost(model_responses) do
    calculate_total_cost(model_responses)
  end

  @doc """
  Calculate cost for hedged requests.

  If hedge fires, you pay for both requests.
  """
  def hedging_cost(primary_response, hedge_response) do
    primary_cost =
      case primary_response do
        {:ok, resp} -> resp.cost_usd
        _ -> 0.0
      end

    hedge_cost =
      case hedge_response do
        {:ok, resp} -> resp.cost_usd
        nil -> 0.0
        _ -> 0.0
      end

    Float.round(primary_cost + hedge_cost, 6)
  end

  @doc """
  Compare costs between different strategies.
  """
  def cost_comparison(single_model_cost, ensemble_cost) do
    overhead = ensemble_cost - single_model_cost
    overhead_pct = overhead / single_model_cost * 100

    %{
      single_model: Float.round(single_model_cost, 6),
      ensemble: Float.round(ensemble_cost, 6),
      overhead: Float.round(overhead, 6),
      overhead_pct: Float.round(overhead_pct, 2)
    }
  end

  @doc """
  Calculate cost efficiency: accuracy per dollar spent.
  """
  def cost_efficiency(accuracy, total_cost) do
    if total_cost > 0 do
      Float.round(accuracy / total_cost, 2)
    else
      0.0
    end
  end

  @doc """
  Estimate costs for an experiment before running.
  """
  def estimate_experiment_cost(num_queries, models, opts \\ []) do
    strategy = Keyword.get(opts, :strategy, :single_model)

    base_cost_per_query =
      case strategy do
        :single_model ->
          # Use cheapest model
          models
          |> Enum.map(& &1.cost_per_query)
          |> Enum.min()

        :ensemble ->
          # All models run in parallel
          models
          |> Enum.map(& &1.cost_per_query)
          |> Enum.sum()

        :cascade ->
          # On average, runs 60% of models before stopping
          total = models |> Enum.map(& &1.cost_per_query) |> Enum.sum()
          total * 0.6

        :hedging ->
          # Assume 15% hedge firing rate
          primary_cost = List.first(models).cost_per_query
          hedge_rate = 0.15
          primary_cost * (1 + hedge_rate)
      end

    total_cost = base_cost_per_query * num_queries

    %{
      strategy: strategy,
      num_queries: num_queries,
      cost_per_query: Float.round(base_cost_per_query, 6),
      total_cost: Float.round(total_cost, 4),
      models_used: length(models)
    }
  end
end
