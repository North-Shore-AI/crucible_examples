defmodule CrucibleExamples.Mock.Models do
  @moduledoc """
  Mock LLM models with realistic behavior simulation.

  This module simulates 5 different LLM models with varying:
  - Accuracy profiles (85%-94%)
  - Latency distributions
  - Cost per query
  - Response variation (models disagree ~15% of the time)
  """

  alias CrucibleExamples.Mock.Latency

  @models [
    %{
      id: :gpt4,
      name: "GPT-4",
      accuracy: 0.94,
      cost_per_query: 0.005,
      latency_profile: :medium,
      vendor: "OpenAI"
    },
    %{
      id: :claude3,
      name: "Claude-3",
      accuracy: 0.93,
      cost_per_query: 0.003,
      latency_profile: :fast,
      vendor: "Anthropic"
    },
    %{
      id: :gemini_pro,
      name: "Gemini Pro",
      accuracy: 0.90,
      cost_per_query: 0.001,
      latency_profile: :medium,
      vendor: "Google"
    },
    %{
      id: :llama3,
      name: "Llama-3-70B",
      accuracy: 0.87,
      cost_per_query: 0.0002,
      latency_profile: :fast,
      vendor: "Meta"
    },
    %{
      id: :mixtral,
      name: "Mixtral-8x7B",
      accuracy: 0.89,
      cost_per_query: 0.0008,
      latency_profile: :medium,
      vendor: "Mistral AI"
    }
  ]

  @doc """
  Get all available mock models.
  """
  def all_models, do: @models

  @doc """
  Get a specific model by ID.
  """
  def get_model(model_id) do
    Enum.find(@models, fn m -> m.id == model_id end)
  end

  @doc """
  Simulate a query to a specific model.

  Returns a mock response with:
  - answer: The model's answer
  - confidence: 0.0-1.0 confidence score
  - latency_ms: Simulated latency
  - cost_usd: Cost of this query
  - metadata: Additional model metadata

  ## Options
  - `:deterministic` - Use seed for reproducible responses (default: false)
  - `:inject_error` - Force error response (default: false, 1% natural error rate)
  """
  def query(model_id, question, correct_answer, opts \\ []) do
    model = get_model(model_id)

    if is_nil(model) do
      {:error, :model_not_found}
    else
      # Simulate latency
      latency_ms = Latency.simulate(model.latency_profile)

      # Simulate processing (sleep for realistic feel in demos)
      if opts[:simulate_delay], do: Process.sleep(min(latency_ms, 500))

      # Simulate potential errors (1% of the time, unless forced)
      error_rate = if opts[:inject_error], do: 1.0, else: 0.01

      if :rand.uniform() < error_rate do
        {:error, simulate_error()}
      else
        # Generate response
        answer = generate_answer(model, question, correct_answer, opts)
        confidence = generate_confidence(model, answer == correct_answer)

        {:ok,
         %{
           model_id: model_id,
           model_name: model.name,
           answer: answer,
           confidence: confidence,
           latency_ms: latency_ms,
           cost_usd: model.cost_per_query,
           timestamp: DateTime.utc_now(),
           metadata: %{
             vendor: model.vendor,
             accuracy_profile: model.accuracy
           }
         }}
      end
    end
  end

  @doc """
  Simulate multiple models querying in parallel (for ensemble demo).
  """
  def query_ensemble(model_ids, question, correct_answer, opts \\ []) do
    model_ids
    |> Enum.map(fn model_id ->
      Task.async(fn ->
        {model_id, query(model_id, question, correct_answer, opts)}
      end)
    end)
    |> Enum.map(&Task.await(&1, 10_000))
    |> Enum.into(%{})
  end

  # Private functions

  defp generate_answer(model, _question, correct_answer, opts) do
    # Use deterministic seed if provided
    if opts[:deterministic] do
      :rand.seed(:exsplus, {model.id, opts[:seed], 42})
    end

    # Model answers correctly based on its accuracy profile
    if :rand.uniform() < model.accuracy do
      correct_answer
    else
      # Generate plausible wrong answer
      generate_wrong_answer(correct_answer)
    end
  end

  defp generate_confidence(model, is_correct) do
    # Higher accuracy models are more confident
    base_confidence = model.accuracy

    # Correct answers get higher confidence
    adjustment = if is_correct, do: 0.05, else: -0.10

    # Add some randomness
    noise = (:rand.uniform() - 0.5) * 0.1

    (base_confidence + adjustment + noise)
    |> max(0.0)
    |> min(1.0)
    |> Float.round(3)
  end

  defp generate_wrong_answer(correct_answer) when is_binary(correct_answer) do
    # For string answers, generate plausible alternatives
    alternatives = [
      "Option A",
      "Option B",
      "Option C",
      "Option D",
      "Insufficient information",
      "Cannot be determined"
    ]

    alternatives
    |> Enum.reject(&(&1 == correct_answer))
    |> Enum.random()
  end

  defp generate_wrong_answer(correct_answer) when is_number(correct_answer) do
    # For numeric answers, generate nearby wrong answers
    variation = :rand.uniform() * 0.3 + 0.1
    sign = if :rand.uniform() > 0.5, do: 1, else: -1

    (correct_answer * (1 + sign * variation))
    |> Float.round(2)
  end

  defp generate_wrong_answer(_), do: "Error: Invalid answer type"

  defp simulate_error do
    errors = [
      :timeout,
      :rate_limit_exceeded,
      :service_unavailable,
      :invalid_request,
      :model_overloaded
    ]

    Enum.random(errors)
  end

  @doc """
  Get statistics about model disagreement for a set of responses.
  """
  def analyze_consensus(responses) do
    # Extract answers
    answers =
      responses
      |> Map.values()
      |> Enum.map(fn
        {:ok, response} -> response.answer
        {:error, _} -> :error
      end)
      |> Enum.reject(&(&1 == :error))

    total_responses = length(answers)

    if total_responses == 0 do
      %{consensus: 0.0, agreement_rate: 0.0, majority_answer: nil}
    else
      # Count occurrences of each answer
      answer_counts =
        answers
        |> Enum.frequencies()

      # Find majority answer
      {majority_answer, majority_count} =
        answer_counts
        |> Enum.max_by(fn {_answer, count} -> count end)

      consensus_rate = majority_count / total_responses

      %{
        consensus: Float.round(consensus_rate, 3),
        agreement_rate: Float.round(consensus_rate, 3),
        majority_answer: majority_answer,
        total_responses: total_responses,
        unanimous: length(Map.keys(answer_counts)) == 1,
        answer_distribution: answer_counts
      }
    end
  end
end
