#!/usr/bin/env elixir

# Datasets Demo
# Demonstrates available benchmark questions

IO.puts("\n=== Datasets Demo ===\n")

alias CrucibleExamples.Mock.Datasets

# Medical questions
IO.puts("=== Medical Questions ===\n")
medical = Datasets.medical_questions()
IO.puts("Total: #{length(medical)} questions\n")

for q <- Enum.take(medical, 2) do
  IO.puts("Q#{q.id} (#{q.difficulty}): #{q.question}")
  IO.puts("Answer: #{q.correct_answer}")
  IO.puts("")
end

# Math problems
IO.puts("=== Math Problems ===\n")
math = Datasets.math_problems()
IO.puts("Total: #{length(math)} problems\n")

for p <- Enum.take(math, 2) do
  IO.puts("Q#{p.id} (#{p.difficulty}): #{p.question}")
  IO.puts("Answer: #{p.correct_answer}")
  IO.puts("")
end

# General knowledge
IO.puts("=== General Knowledge ===\n")
general = Datasets.general_knowledge()
IO.puts("Total: #{length(general)} questions\n")

for q <- Enum.take(general, 2) do
  IO.puts("Q#{q.id} (#{q.subject}): #{q.question}")
  IO.puts("Options: #{Enum.join(q.options, ", ")}")
  IO.puts("Answer: #{q.correct_answer}")
  IO.puts("")
end

# Code problems
IO.puts("=== Code Problems ===\n")
code = Datasets.code_problems()
IO.puts("Total: #{length(code)} problems\n")

for p <- Enum.take(code, 1) do
  IO.puts("Q#{p.id} (#{p.language}): #{p.question}")
  IO.puts("Test Cases: #{length(p.test_cases)}")
  IO.puts("")
end

# Sampling
IO.puts("=== Random Sampling ===\n")

for category <- [:medical, :math, :general] do
  sample = Datasets.sample(category)
  IO.puts("#{String.upcase(to_string(category))}: Q#{sample.id}")
end

IO.puts("")

# Batching
IO.puts("=== Batch Generation ===\n")
batch = Datasets.batch(:math, 10)
IO.puts("Generated #{length(batch)} math problems for experiment")
IO.puts("")
