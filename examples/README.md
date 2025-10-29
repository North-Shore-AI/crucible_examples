# Crucible Examples - Runnable Scripts

This directory contains standalone example scripts that demonstrate the Crucible Examples mock system and framework capabilities without requiring the Phoenix web server.

## Available Examples

### Mock System Demonstrations

#### 1. Mock Models Demo (`mock_models_demo.exs`)
Demonstrates the 5 mock LLM models and their capabilities.

```bash
mix run examples/mock_models_demo.exs
```

**Features:**
- Lists all 5 available models with specs
- Single query test
- Deterministic mode demonstration
- Error injection test

**Output:** Model profiles, response details, and behavior validation

---

#### 2. Latency Simulation Demo (`latency_demo.exs`)
Shows realistic latency distributions and hedging scenarios.

```bash
mix run examples/latency_demo.exs
```

**Features:**
- Latency profiles (fast, medium, slow)
- P50/P95/P99 percentile analysis
- Batch simulation statistics
- Hedging simulation with 10 scenarios
- Hedge firing rate analysis

**Output:** Latency distributions, hedging outcomes, firing rates

---

#### 3. Datasets Demo (`datasets_demo.exs`)
Showcases the benchmark question datasets.

```bash
mix run examples/datasets_demo.exs
```

**Features:**
- Medical diagnosis questions
- Math word problems
- General knowledge questions
- Code generation prompts
- Random sampling
- Batch generation

**Output:** Sample questions from each category

---

### Interactive Feature Demonstrations

#### 4. Ensemble Reliability Demo (`ensemble_demo.exs`)
Demonstrates multi-model voting for improved reliability.

```bash
mix run examples/ensemble_demo.exs
```

**Features:**
- Queries 5 models in parallel
- Calculates consensus and agreement rate
- Cost comparison (single vs ensemble)
- Accuracy validation

**Output:** Individual model responses, consensus analysis, cost breakdown

**Sample Output:**
```
Question: A 45-year-old patient presents with fatigue...
Correct Answer: Hypothyroidism

GPT-4: Hypothyroidism (100.0% confidence)
Claude-3: Hypothyroidism (95.5% confidence)
...

Majority Answer: Hypothyroidism
Agreement Rate: 80.0%
Ensemble Answer: ✓ CORRECT
```

---

#### 5. Request Hedging Demo (`hedging_demo.exs`)
Shows tail latency reduction through backup requests.

```bash
mix run examples/hedging_demo.exs
```

**Features:**
- Baseline vs hedged latency comparison
- 100-sample batch simulation
- P95/P99 improvement calculation
- Hedge firing statistics
- Cost overhead analysis

**Output:** Latency distributions, improvement percentages, cost analysis

**Sample Output:**
```
Baseline P99: 4430ms
Hedged P99: 2362ms
P99 Improvement: 46.7%
Hedge Firing Rate: 37.0%
Cost Overhead: 37.0%
```

---

#### 6. Statistical Comparison Demo (`stats_demo.exs`)
A/B testing of two models with proper statistics.

```bash
mix run examples/stats_demo.exs
```

**Features:**
- Compares GPT-4 vs Claude-3
- 50 math problems per model
- Accuracy, latency, and cost metrics
- Winner determination

**Output:** Comparative results, accuracy differences, winner declaration

**Sample Output:**
```
Model A (GPT-4):
  Accuracy: 88.0%
  Avg Latency: 1487ms
  Total Cost: $0.25

Model B (Claude-3):
  Accuracy: 96.0%
  Avg Latency: 383ms
  Total Cost: $0.15

Winner: Model B wins on accuracy!
```

---

## Running All Examples

You can run all examples sequentially to see the full demonstration:

```bash
for script in examples/*.exs; do
  echo "Running $script..."
  mix run "$script"
  echo "---"
done
```

## Example Use Cases

### Testing the Mock System
Run the mock demonstrations to verify the system works correctly:
```bash
mix run examples/mock_models_demo.exs
mix run examples/latency_demo.exs
mix run examples/datasets_demo.exs
```

### Understanding Framework Features
Run the feature demonstrations to learn how each capability works:
```bash
mix run examples/ensemble_demo.exs
mix run examples/hedging_demo.exs
mix run examples/stats_demo.exs
```

### Benchmarking Performance
Modify the sample sizes in the scripts to test performance at scale:
```elixir
# In hedging_demo.exs, change:
num_samples = 1000  # Instead of 100

# In stats_demo.exs, change:
sample_size = 100   # Instead of 50
```

## Customization

All examples can be easily modified to test different scenarios:

### Change Models
```elixir
# In any demo, replace model IDs:
model_ids = [:gpt4, :claude3, :llama3]  # Use different combinations
```

### Change Latency Profiles
```elixir
# In hedging_demo.exs:
profile = :slow  # Instead of :medium
hedge_delay = 2000  # Instead of 1000
```

### Change Question Categories
```elixir
# In stats_demo.exs:
questions = Datasets.batch(:medical, sample_size)  # Instead of :math
```

## Output Format

All examples output to stdout with:
- Clear section headers
- Formatted metrics
- Success/failure indicators
- Cost and performance analysis

Examples can be piped or redirected for analysis:
```bash
mix run examples/ensemble_demo.exs > results.txt
mix run examples/hedging_demo.exs | grep "P99"
```

## Dependencies

These examples use only the mock system and do not require:
- Phoenix web server
- Database
- External APIs
- API keys

They run entirely in-process using the simulated LLM system.

## Development

Feel free to create new examples following the same pattern:

```elixir
#!/usr/bin/env elixir

# Your Example Demo
# Brief description

IO.puts("\n=== Your Demo Name ===\n")

alias CrucibleExamples.Mock.{Models, Datasets, Latency, Pricing}

# Your demo code here

IO.puts("")
```

## Testing

All examples should run successfully and produce output. To verify:

```bash
# Run an example and check exit code
mix run examples/ensemble_demo.exs
echo $?  # Should be 0
```

## Notes

- Warnings about `file_system` and `live-reload` are expected and safe to ignore
- These are development-only features for the Phoenix server
- Examples run without these features
- Random variation is expected between runs (this is realistic!)
- Use deterministic mode in Models.query for reproducible results

---

**For the full interactive experience, run `mix phx.server` and visit http://localhost:4000**
