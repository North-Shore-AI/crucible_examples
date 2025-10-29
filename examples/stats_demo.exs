#!/usr/bin/env elixir

# Statistical Comparison Demo
# Demonstrates proper A/B testing of two models

IO.puts("\n=== Statistical Comparison Demo ===\n")

alias CrucibleExamples.Mock.{Models, Datasets}

# Configuration
model_a = :gpt4
model_b = :claude3
sample_size = 50

IO.puts("Comparing Models:")
IO.puts("  Model A: #{Models.get_model(model_a).name}")
IO.puts("  Model B: #{Models.get_model(model_b).name}")
IO.puts("  Sample Size: #{sample_size}")
IO.puts("")

# Get test questions
questions = Datasets.batch(:math, sample_size)

IO.puts("Running experiment...")

# Test Model A
results_a =
  questions
  |> Enum.map(fn q ->
    case Models.query(model_a, q.question, q.correct_answer) do
      {:ok, resp} ->
        %{
          correct: resp.answer == q.correct_answer,
          latency: resp.latency_ms,
          cost: resp.cost_usd
        }

      {:error, _} ->
        %{correct: false, latency: 0, cost: 0.0}
    end
  end)

# Test Model B
results_b =
  questions
  |> Enum.map(fn q ->
    case Models.query(model_b, q.question, q.correct_answer) do
      {:ok, resp} ->
        %{
          correct: resp.answer == q.correct_answer,
          latency: resp.latency_ms,
          cost: resp.cost_usd
        }

      {:error, _} ->
        %{correct: false, latency: 0, cost: 0.0}
    end
  end)

IO.puts("Experiment complete!\n")

# Calculate metrics
accuracy_a = Enum.count(results_a, & &1.correct) / sample_size
accuracy_b = Enum.count(results_b, & &1.correct) / sample_size

avg_latency_a = Enum.sum(Enum.map(results_a, & &1.latency)) / sample_size
avg_latency_b = Enum.sum(Enum.map(results_b, & &1.latency)) / sample_size

total_cost_a = Enum.sum(Enum.map(results_a, & &1.cost))
total_cost_b = Enum.sum(Enum.map(results_b, & &1.cost))

IO.puts("--- Results ---")
IO.puts("\nModel A (#{Models.get_model(model_a).name}):")
IO.puts("  Accuracy: #{Float.round(accuracy_a * 100, 1)}%")
IO.puts("  Avg Latency: #{Float.round(avg_latency_a, 0)}ms")
IO.puts("  Total Cost: $#{Float.round(total_cost_a, 4)}")

IO.puts("\nModel B (#{Models.get_model(model_b).name}):")
IO.puts("  Accuracy: #{Float.round(accuracy_b * 100, 1)}%")
IO.puts("  Avg Latency: #{Float.round(avg_latency_b, 0)}ms")
IO.puts("  Total Cost: $#{Float.round(total_cost_b, 4)}")

# Determine winner
IO.puts("\n--- Comparison ---")

accuracy_diff = accuracy_b - accuracy_a
IO.puts("Accuracy Difference: #{Float.round(accuracy_diff * 100, 1)}pp")

latency_diff = avg_latency_b - avg_latency_a
IO.puts("Latency Difference: #{Float.round(latency_diff, 0)}ms")

cost_diff = total_cost_b - total_cost_a
IO.puts("Cost Difference: $#{Float.round(cost_diff, 4)}")

IO.puts("\n--- Winner ---")

cond do
  accuracy_b > accuracy_a ->
    IO.puts("Model B wins on accuracy!")

  accuracy_a > accuracy_b ->
    IO.puts("Model A wins on accuracy!")

  true ->
    IO.puts("Tie on accuracy!")
end

IO.puts("")
