defmodule CrucibleExamples.Mock.ModelsTest do
  use ExUnit.Case, async: true
  alias CrucibleExamples.Mock.Models

  describe "all_models/0" do
    test "returns all 5 models" do
      models = Models.all_models()
      assert length(models) == 5
    end

    test "each model has required fields" do
      models = Models.all_models()

      for model <- models do
        assert Map.has_key?(model, :id)
        assert Map.has_key?(model, :name)
        assert Map.has_key?(model, :accuracy)
        assert Map.has_key?(model, :cost_per_query)
        assert Map.has_key?(model, :latency_profile)
        assert Map.has_key?(model, :vendor)
      end
    end

    test "model accuracies are in expected range" do
      models = Models.all_models()

      for model <- models do
        assert model.accuracy >= 0.80
        assert model.accuracy <= 1.0
      end
    end
  end

  describe "get_model/1" do
    test "returns correct model for valid ID" do
      model = Models.get_model(:gpt4)
      assert model.id == :gpt4
      assert model.name == "GPT-4"
    end

    test "returns nil for invalid ID" do
      model = Models.get_model(:invalid_model)
      assert is_nil(model)
    end
  end

  describe "query/4" do
    test "returns ok tuple with valid model" do
      result = Models.query(:gpt4, "test question", "correct answer")
      assert {:ok, response} = result
      assert response.model_id == :gpt4
      assert response.model_name == "GPT-4"
    end

    test "returns error for invalid model" do
      result = Models.query(:invalid, "test", "answer")
      assert {:error, :model_not_found} = result
    end

    test "response includes all required fields" do
      {:ok, response} = Models.query(:gpt4, "question", "answer")

      assert Map.has_key?(response, :model_id)
      assert Map.has_key?(response, :model_name)
      assert Map.has_key?(response, :answer)
      assert Map.has_key?(response, :confidence)
      assert Map.has_key?(response, :latency_ms)
      assert Map.has_key?(response, :cost_usd)
      assert Map.has_key?(response, :timestamp)
      assert Map.has_key?(response, :metadata)
    end

    test "confidence is between 0 and 1" do
      {:ok, response} = Models.query(:gpt4, "question", "answer")
      assert response.confidence >= 0.0
      assert response.confidence <= 1.0
    end

    test "latency is positive" do
      {:ok, response} = Models.query(:gpt4, "question", "answer")
      assert response.latency_ms > 0
    end

    test "cost matches model profile" do
      {:ok, response} = Models.query(:gpt4, "question", "answer")
      model = Models.get_model(:gpt4)
      assert response.cost_usd == model.cost_per_query
    end

    test "deterministic mode produces consistent results" do
      opts = [deterministic: true, seed: 12345]
      {:ok, resp1} = Models.query(:gpt4, "question", "answer", opts)
      {:ok, resp2} = Models.query(:gpt4, "question", "answer", opts)

      # With same seed, same model, same question - should get same answer
      assert resp1.answer == resp2.answer
    end

    test "inject_error option forces error" do
      result = Models.query(:gpt4, "question", "answer", inject_error: true)
      assert {:error, _reason} = result
    end
  end

  describe "query_ensemble/4" do
    test "queries all provided models" do
      model_ids = [:gpt4, :claude3, :gemini_pro]
      results = Models.query_ensemble(model_ids, "question", "answer")

      assert map_size(results) == 3
      assert Map.has_key?(results, :gpt4)
      assert Map.has_key?(results, :claude3)
      assert Map.has_key?(results, :gemini_pro)
    end

    test "returns responses for all valid models" do
      model_ids = [:gpt4, :claude3]
      results = Models.query_ensemble(model_ids, "question", "answer")

      for {_model_id, result} <- results do
        assert {:ok, _response} = result
      end
    end
  end

  describe "analyze_consensus/1" do
    test "calculates consensus correctly with all same answers" do
      responses = %{
        gpt4: {:ok, %{answer: "A"}},
        claude3: {:ok, %{answer: "A"}},
        gemini_pro: {:ok, %{answer: "A"}}
      }

      result = Models.analyze_consensus(responses)
      assert result.consensus == 1.0
      assert result.unanimous == true
      assert result.majority_answer == "A"
    end

    test "calculates consensus with mixed answers" do
      responses = %{
        gpt4: {:ok, %{answer: "A"}},
        claude3: {:ok, %{answer: "A"}},
        gemini_pro: {:ok, %{answer: "B"}}
      }

      result = Models.analyze_consensus(responses)
      assert result.consensus > 0.5
      assert result.unanimous == false
      assert result.majority_answer == "A"
    end

    test "handles errors in responses" do
      responses = %{
        gpt4: {:ok, %{answer: "A"}},
        claude3: {:error, :timeout},
        gemini_pro: {:ok, %{answer: "A"}}
      }

      result = Models.analyze_consensus(responses)
      assert result.total_responses == 2
      assert result.majority_answer == "A"
    end

    test "handles all error responses" do
      responses = %{
        gpt4: {:error, :timeout},
        claude3: {:error, :rate_limit}
      }

      result = Models.analyze_consensus(responses)
      assert result.consensus == 0.0
      assert result.majority_answer == nil
    end
  end
end
