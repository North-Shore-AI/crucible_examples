defmodule CrucibleExamples.Scenarios.EnsembleDemo do
  @moduledoc """
  Scenario: Medical Diagnosis Assistant with Ensemble Voting

  Demonstrates how ensemble voting achieves higher reliability (96-99%)
  compared to single model (89-92%) on high-stakes medical decisions.

  Shows:
  - 5 models voting on medical questions
  - Different voting strategies (majority, weighted, unanimous)
  - Real-time consensus tracking
  - Cost vs accuracy trade-offs
  """

  alias CrucibleExamples.Mock.{Models, Datasets, Pricing}

  @doc """
  Run ensemble prediction on a medical question.

  Returns the ensemble result with all model responses, voting outcome,
  consensus metrics, and cost analysis.
  """
  def run_ensemble(question_id, voting_strategy \\ :majority, opts \\ []) do
    # Get the medical question
    question = get_question(question_id)

    # All 5 models participate
    model_ids = [:gpt4, :claude3, :gemini_pro, :llama3, :mixtral]

    # Query all models in parallel
    responses =
      Models.query_ensemble(
        model_ids,
        question.question,
        question.correct_answer,
        opts
      )

    # Apply voting strategy
    vote_result = apply_voting_strategy(responses, voting_strategy)

    # Calculate consensus
    consensus = Models.analyze_consensus(responses)

    # Calculate costs
    total_cost = Pricing.ensemble_cost(responses)
    single_model_cost = Models.get_model(:gpt4).cost_per_query

    # Build result
    %{
      question: question,
      model_responses: responses,
      voting_strategy: voting_strategy,
      vote_result: vote_result,
      consensus: consensus,
      cost_analysis: %{
        ensemble_cost: total_cost,
        single_model_cost: single_model_cost,
        overhead: total_cost - single_model_cost,
        overhead_pct:
          ((total_cost - single_model_cost) / single_model_cost * 100) |> Float.round(1)
      },
      is_correct: vote_result.final_answer == question.correct_answer,
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Run a batch of ensemble predictions for statistical analysis.
  """
  def run_batch(num_questions, voting_strategy \\ :majority, opts \\ []) do
    questions = Datasets.medical_questions()

    1..num_questions
    |> Enum.map(fn i ->
      question_id = rem(i - 1, length(questions)) + 1
      run_ensemble(question_id, voting_strategy, opts)
    end)
  end

  @doc """
  Compare single model vs ensemble performance.
  """
  def compare_single_vs_ensemble(num_questions \\ 10) do
    questions = Datasets.medical_questions()

    results =
      1..num_questions
      |> Enum.map(fn i ->
        question_id = rem(i - 1, length(questions)) + 1
        question = get_question(question_id)

        # Single model (GPT-4)
        {:ok, single_response} =
          Models.query(:gpt4, question.question, question.correct_answer)

        # Ensemble (all 5 models)
        ensemble_result = run_ensemble(question_id, :majority)

        %{
          question_id: question_id,
          single_correct: single_response.answer == question.correct_answer,
          ensemble_correct: ensemble_result.is_correct,
          single_cost: single_response.cost_usd,
          ensemble_cost: ensemble_result.cost_analysis.ensemble_cost,
          consensus: ensemble_result.consensus.consensus
        }
      end)

    # Calculate statistics
    single_accuracy = Enum.count(results, & &1.single_correct) / length(results)
    ensemble_accuracy = Enum.count(results, & &1.ensemble_correct) / length(results)

    avg_single_cost =
      results |> Enum.map(& &1.single_cost) |> Enum.sum() |> Kernel./(length(results))

    avg_ensemble_cost =
      results |> Enum.map(& &1.ensemble_cost) |> Enum.sum() |> Kernel./(length(results))

    avg_consensus = results |> Enum.map(& &1.consensus) |> Enum.sum() |> Kernel./(length(results))

    %{
      num_questions: num_questions,
      single_model: %{
        accuracy: Float.round(single_accuracy, 3),
        avg_cost: Float.round(avg_single_cost, 6)
      },
      ensemble: %{
        accuracy: Float.round(ensemble_accuracy, 3),
        avg_cost: Float.round(avg_ensemble_cost, 6),
        avg_consensus: Float.round(avg_consensus, 3)
      },
      improvement: %{
        accuracy_gain: Float.round((ensemble_accuracy - single_accuracy) * 100, 1),
        cost_multiplier: Float.round(avg_ensemble_cost / avg_single_cost, 1)
      },
      results: results
    }
  end

  # Private functions

  defp get_question(question_id) do
    Datasets.medical_questions()
    |> Enum.find(fn q -> q.id == question_id end)
  end

  defp apply_voting_strategy(responses, strategy) do
    successful_responses =
      responses
      |> Enum.map(fn {model_id, result} ->
        case result do
          {:ok, response} -> {model_id, response}
          {:error, _} -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    case strategy do
      :majority -> majority_vote(successful_responses)
      :weighted -> weighted_vote(successful_responses)
      :unanimous -> unanimous_vote(successful_responses)
      :best_confidence -> best_confidence_vote(successful_responses)
    end
  end

  defp majority_vote(responses) do
    # Count votes for each answer
    vote_counts =
      responses
      |> Enum.map(fn {_model_id, response} -> response.answer end)
      |> Enum.frequencies()

    # Find the answer with most votes
    {final_answer, vote_count} =
      vote_counts
      |> Enum.max_by(fn {_answer, count} -> count end)

    %{
      strategy: :majority,
      final_answer: final_answer,
      vote_count: vote_count,
      total_votes: length(responses),
      vote_distribution: vote_counts,
      winning_models: get_models_with_answer(responses, final_answer)
    }
  end

  defp weighted_vote(responses) do
    # Weight each vote by confidence
    weighted_votes =
      responses
      |> Enum.group_by(fn {_model_id, response} -> response.answer end)
      |> Enum.map(fn {answer, model_responses} ->
        total_confidence =
          model_responses
          |> Enum.map(fn {_model_id, response} -> response.confidence end)
          |> Enum.sum()

        {answer, total_confidence}
      end)

    {final_answer, total_confidence} =
      weighted_votes
      |> Enum.max_by(fn {_answer, confidence} -> confidence end)

    %{
      strategy: :weighted,
      final_answer: final_answer,
      total_confidence: Float.round(total_confidence, 2),
      weighted_votes: weighted_votes,
      winning_models: get_models_with_answer(responses, final_answer)
    }
  end

  defp unanimous_vote(responses) do
    # All models must agree
    answers =
      responses
      |> Enum.map(fn {_model_id, response} -> response.answer end)
      |> Enum.uniq()

    if length(answers) == 1 do
      %{
        strategy: :unanimous,
        final_answer: List.first(answers),
        unanimous: true,
        total_votes: length(responses)
      }
    else
      # Fall back to majority if not unanimous
      majority_result = majority_vote(responses)

      %{
        strategy: :unanimous,
        final_answer: majority_result.final_answer,
        unanimous: false,
        fallback_to_majority: true,
        vote_distribution: majority_result.vote_distribution
      }
    end
  end

  defp best_confidence_vote(responses) do
    # Choose the answer with the highest confidence from any model
    {model_id, best_response} =
      responses
      |> Enum.max_by(fn {_model_id, response} -> response.confidence end)

    %{
      strategy: :best_confidence,
      final_answer: best_response.answer,
      confidence: best_response.confidence,
      winning_model: model_id,
      model_name: best_response.model_name
    }
  end

  defp get_models_with_answer(responses, answer) do
    responses
    |> Enum.filter(fn {_model_id, response} -> response.answer == answer end)
    |> Enum.map(fn {model_id, _response} -> model_id end)
  end
end
