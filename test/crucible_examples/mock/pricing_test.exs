defmodule CrucibleExamples.Mock.PricingTest do
  use ExUnit.Case, async: true
  alias CrucibleExamples.Mock.Pricing

  describe "calculate_total_cost/1" do
    test "calculates cost from successful responses" do
      responses = %{
        gpt4: {:ok, %{cost_usd: 0.005}},
        claude3: {:ok, %{cost_usd: 0.003}}
      }

      total = Pricing.calculate_total_cost(responses)
      assert total == 0.008
    end

    test "ignores error responses" do
      responses = %{
        gpt4: {:ok, %{cost_usd: 0.005}},
        claude3: {:error, :timeout}
      }

      total = Pricing.calculate_total_cost(responses)
      assert total == 0.005
    end

    test "returns 0.0 for all errors" do
      responses = %{
        gpt4: {:error, :timeout},
        claude3: {:error, :rate_limit}
      }

      total = Pricing.calculate_total_cost(responses)
      assert total == 0.0
    end

    test "returns 0.0 for empty responses" do
      total = Pricing.calculate_total_cost(%{})
      assert total == 0.0
    end
  end

  describe "ensemble_cost/1" do
    test "sums costs from all models" do
      responses = %{
        gpt4: {:ok, %{cost_usd: 0.005}},
        claude3: {:ok, %{cost_usd: 0.003}},
        gemini_pro: {:ok, %{cost_usd: 0.001}}
      }

      cost = Pricing.ensemble_cost(responses)
      assert cost == 0.009
    end
  end

  describe "hedging_cost/2" do
    test "calculates cost when hedge fires" do
      primary = {:ok, %{cost_usd: 0.005}}
      hedge = {:ok, %{cost_usd: 0.005}}

      cost = Pricing.hedging_cost(primary, hedge)
      assert cost == 0.010
    end

    test "calculates cost when hedge does not fire" do
      primary = {:ok, %{cost_usd: 0.005}}
      hedge = nil

      cost = Pricing.hedging_cost(primary, hedge)
      assert cost == 0.005
    end

    test "handles primary error" do
      primary = {:error, :timeout}
      hedge = {:ok, %{cost_usd: 0.005}}

      cost = Pricing.hedging_cost(primary, hedge)
      assert cost == 0.005
    end

    test "handles both errors" do
      primary = {:error, :timeout}
      hedge = {:error, :rate_limit}

      cost = Pricing.hedging_cost(primary, hedge)
      assert cost == 0.0
    end
  end

  describe "cost_comparison/2" do
    test "calculates overhead correctly" do
      comparison = Pricing.cost_comparison(0.005, 0.020)

      assert comparison.single_model == 0.005
      assert comparison.ensemble == 0.020
      assert comparison.overhead == 0.015
      assert comparison.overhead_pct == 300.0
    end

    test "handles equal costs" do
      comparison = Pricing.cost_comparison(0.005, 0.005)

      assert comparison.overhead == 0.0
      assert comparison.overhead_pct == 0.0
    end
  end

  describe "cost_efficiency/2" do
    test "calculates efficiency correctly" do
      efficiency = Pricing.cost_efficiency(0.95, 0.005)
      assert efficiency == 190.0
    end

    test "handles zero cost" do
      efficiency = Pricing.cost_efficiency(0.95, 0.0)
      assert efficiency == 0.0
    end

    test "higher accuracy per dollar is better" do
      high_eff = Pricing.cost_efficiency(0.95, 0.001)
      low_eff = Pricing.cost_efficiency(0.90, 0.005)
      assert high_eff > low_eff
    end
  end

  describe "estimate_experiment_cost/3" do
    test "estimates single model strategy" do
      models = [
        %{cost_per_query: 0.005},
        %{cost_per_query: 0.003}
      ]

      estimate = Pricing.estimate_experiment_cost(100, models, strategy: :single_model)

      assert estimate.strategy == :single_model
      assert estimate.num_queries == 100
      assert estimate.cost_per_query == 0.003
      assert estimate.total_cost == 0.3
    end

    test "estimates ensemble strategy" do
      models = [
        %{cost_per_query: 0.005},
        %{cost_per_query: 0.003},
        %{cost_per_query: 0.001}
      ]

      estimate = Pricing.estimate_experiment_cost(100, models, strategy: :ensemble)

      assert estimate.strategy == :ensemble
      assert estimate.cost_per_query == 0.009
      assert estimate.total_cost == 0.9
    end

    test "estimates cascade strategy" do
      models = [
        %{cost_per_query: 0.005},
        %{cost_per_query: 0.003}
      ]

      estimate = Pricing.estimate_experiment_cost(100, models, strategy: :cascade)

      assert estimate.strategy == :cascade
      # Should be about 60% of total
      assert estimate.cost_per_query < 0.008
    end

    test "estimates hedging strategy" do
      models = [
        %{cost_per_query: 0.005}
      ]

      estimate = Pricing.estimate_experiment_cost(100, models, strategy: :hedging)

      assert estimate.strategy == :hedging
      # Should be slightly more than single due to hedge firing
      assert estimate.cost_per_query > 0.005
      assert estimate.cost_per_query < 0.006
    end

    test "defaults to single model strategy" do
      models = [%{cost_per_query: 0.005}]
      estimate = Pricing.estimate_experiment_cost(100, models)

      assert estimate.strategy == :single_model
    end
  end
end
