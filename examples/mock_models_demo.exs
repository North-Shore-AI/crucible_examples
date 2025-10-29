#!/usr/bin/env elixir

# Mock Models Demo
# Demonstrates the mock LLM system capabilities

IO.puts("\n=== Mock Models Demo ===\n")

alias CrucibleExamples.Mock.{Models, Datasets}

IO.puts("Available Models:")
IO.puts("")

for model <- Models.all_models() do
  IO.puts("#{model.name} (#{model.vendor}):")
  IO.puts("  Accuracy: #{Float.round(model.accuracy * 100, 1)}%")
  IO.puts("  Cost per Query: $#{model.cost_per_query}")
  IO.puts("  Latency Profile: #{model.latency_profile}")
  IO.puts("")
end

# Test a single query
IO.puts("--- Single Query Test ---")
question = Datasets.sample(:medical)
IO.puts("Question: #{question.question}")
IO.puts("")

{:ok, response} = Models.query(:gpt4, question.question, question.correct_answer)

IO.puts("Response from #{response.model_name}:")
IO.puts("  Answer: #{response.answer}")
IO.puts("  Confidence: #{Float.round(response.confidence * 100, 1)}%")
IO.puts("  Latency: #{response.latency_ms}ms")
IO.puts("  Cost: $#{response.cost_usd}")
IO.puts("  Correct: #{response.answer == question.correct_answer}")
IO.puts("")

# Demonstrate deterministic mode
IO.puts("--- Deterministic Mode Test ---")
opts = [deterministic: true, seed: 12345]

{:ok, resp1} = Models.query(:claude3, "Test question", "Test answer", opts)
{:ok, resp2} = Models.query(:claude3, "Test question", "Test answer", opts)

IO.puts("Response 1 answer: #{resp1.answer}")
IO.puts("Response 2 answer: #{resp2.answer}")
IO.puts("Consistent: #{resp1.answer == resp2.answer}")
IO.puts("")

# Demonstrate error injection
IO.puts("--- Error Injection Test ---")

case Models.query(:gpt4, "test", "answer", inject_error: true) do
  {:error, reason} ->
    IO.puts("Error successfully injected: #{reason}")

  {:ok, _} ->
    IO.puts("Unexpected success")
end

IO.puts("")
