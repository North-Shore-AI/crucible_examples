#!/usr/bin/env elixir

# Ensemble Reliability Demo
# Demonstrates how multiple models voting improves reliability

IO.puts("\n=== Ensemble Reliability Demo ===\n")

alias CrucibleExamples.Mock.{Models, Datasets, Pricing}

# Get a medical question
question = Datasets.sample(:medical)

IO.puts("Question: #{question.question}")
IO.puts("Correct Answer: #{question.correct_answer}")
IO.puts("\n--- Querying 5 Models ---\n")

# Query all 5 models
model_ids = [:gpt4, :claude3, :gemini_pro, :llama3, :mixtral]
responses = Models.query_ensemble(model_ids, question.question, question.correct_answer)

# Display individual responses
for model_id <- model_ids do
  case Map.get(responses, model_id) do
    {:ok, resp} ->
      IO.puts("#{resp.model_name}:")
      IO.puts("  Answer: #{resp.answer}")
      IO.puts("  Confidence: #{Float.round(resp.confidence * 100, 1)}%")
      IO.puts("  Latency: #{resp.latency_ms}ms")
      IO.puts("  Cost: $#{resp.cost_usd}")

    {:error, reason} ->
      IO.puts("#{model_id}: ERROR - #{reason}")
  end

  IO.puts("")
end

# Analyze consensus
consensus = Models.analyze_consensus(responses)

IO.puts("--- Consensus Analysis ---")
IO.puts("Majority Answer: #{consensus.majority_answer}")
IO.puts("Agreement Rate: #{Float.round(consensus.consensus * 100, 1)}%")
IO.puts("Unanimous: #{consensus.unanimous}")
IO.puts("Total Responses: #{consensus.total_responses}")

# Cost analysis
total_cost = Pricing.ensemble_cost(responses)
single_cost = Models.get_model(:gpt4).cost_per_query

IO.puts("\n--- Cost Analysis ---")
IO.puts("Single Model (GPT-4): $#{single_cost}")
IO.puts("Ensemble (5 models): $#{total_cost}")
IO.puts("Cost Overhead: #{Float.round(total_cost / single_cost - 1, 2) * 100}%")

# Verdict
correct = consensus.majority_answer == question.correct_answer
IO.puts("\n--- Result ---")
IO.puts("Ensemble Answer: #{if correct, do: "✓ CORRECT", else: "✗ INCORRECT"}")
IO.puts("")
