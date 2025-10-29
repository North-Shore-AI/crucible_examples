# Crucible Examples

[![Elixir](https://img.shields.io/badge/elixir-1.15+-purple.svg)](https://elixir-lang.org)
[![Phoenix](https://img.shields.io/badge/phoenix-1.8+-orange.svg)](https://phoenixframework.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/North-Shore-AI/crucible_examples/blob/master/LICENSE)

**Interactive Phoenix LiveView demonstrations of the Crucible Framework**

This project showcases the Crucible Framework's components through **mock LLM scenarios with real framework orchestration**. Experience ensemble voting, request hedging, statistical analysis, causal tracing, and production monitoring through beautiful, real-time visualizations.

## 🎯 What is This?

Crucible Examples is a **live, interactive demo application** that helps you:

- **Understand** how Crucible's reliability tools work in practice
- **Visualize** statistical rigor applied to LLM evaluation
- **Experience** real-time ensemble voting, hedging, and optimization
- **Learn** best practices for production ML systems

### Key Feature: Mock LLM + Real Framework

- **Mock LLM calls** simulate realistic model responses, latency, and costs
- **Real Crucible Framework** orchestration, statistics, and analysis
- **No API keys required** - everything runs locally with simulated data
- **Real-time visualization** of framework components in action

## 📊 Interactive Examples

### 1. **Ensemble Reliability Dashboard**
**Scenario**: Medical diagnosis assistant with high-stakes decisions

- Watch 5 models respond to the same query
- See voting strategies (majority, weighted, unanimous) in action
- Real-time consensus metrics and confidence intervals
- Cost/accuracy trade-off visualization

### 2. **Request Hedging Simulator**
**Scenario**: Customer support chatbot with latency requirements

- Visualize tail latency reduction (P99 improvements)
- Compare hedging strategies (fixed, adaptive, percentile-based)
- Live latency histograms and firing indicators
- Cost efficiency metrics (latency improvement per $)

### 3. **Statistical Comparison Lab**
**Scenario**: A/B test comparing two models on math problems

- Configure experiment parameters
- Watch statistical analysis in real-time
- See t-tests, effect sizes, and confidence intervals
- Generate publication-ready reports

### 4. **Causal Trace Explorer**
**Scenario**: Multi-step reasoning with decision transparency

- Interactive timeline of LLM reasoning process
- Explore alternatives considered at each step
- Uncertainty tracking over time
- Searchable event history

### 5. **Production Monitoring Dashboard**
**Scenario**: Continuous model health monitoring

- 30-day historical baseline visualization
- Automated degradation detection with statistical tests
- Alert system based on confidence intervals
- Retraining trigger recommendations

### 6. **Optimization Playground**
**Scenario**: Systematic prompt parameter search

- Define variable search spaces (temperature, tokens, examples)
- Choose optimization strategy (grid, random, Bayesian)
- Watch convergence in real-time
- Validate optimal configuration

## 🚀 Getting Started

### Prerequisites

- Elixir 1.15+ and Erlang/OTP 26+
- Node.js 18+ (for Phoenix assets)
- Phoenix Framework 1.8+

### Installation

```bash
# Clone the repo (if not already)
cd North-Shore-AI

# Navigate to crucible_examples
cd crucible_examples

# Install dependencies
mix deps.get

# Install Node.js dependencies
cd assets && npm install && cd ..

# Start the Phoenix server
mix phx.server
```

Now visit [`localhost:4000`](http://localhost:4000) in your browser.

## 🏗️ Project Structure

```
crucible_examples/
├── lib/
│   ├── crucible_examples/          # Core application logic
│   │   ├── mock/                   # Mock LLM system
│   │   │   ├── models.ex          # Simulated model responses
│   │   │   ├── latency.ex         # Realistic latency distributions
│   │   │   ├── datasets.ex        # Mock benchmark questions
│   │   │   └── pricing.ex         # Cost tracking
│   │   ├── scenarios/              # Demo scenario implementations
│   │   │   ├── ensemble_demo.ex   # Ensemble voting demo
│   │   │   ├── hedging_demo.ex    # Request hedging demo
│   │   │   ├── stats_demo.ex      # Statistical comparison demo
│   │   │   ├── trace_demo.ex      # Causal trace demo
│   │   │   ├── monitoring_demo.ex # Production monitoring demo
│   │   │   └── optimization_demo.ex # Optimization demo
│   │   └── telemetry/              # Event collection
│   └── crucible_examples_web/      # Phoenix web interface
│       ├── live/                   # LiveView modules
│       │   ├── home_live.ex       # Homepage
│       │   ├── ensemble_live.ex   # Ensemble demo LiveView
│       │   ├── hedging_live.ex    # Hedging demo LiveView
│       │   ├── stats_live.ex      # Stats demo LiveView
│       │   ├── trace_live.ex      # Trace explorer LiveView
│       │   ├── monitoring_live.ex # Monitoring dashboard LiveView
│       │   └── optimization_live.ex # Optimization playground LiveView
│       ├── components/             # Reusable components
│       │   ├── charts.ex          # Chart components
│       │   ├── metrics_card.ex    # Metrics display
│       │   ├── model_card.ex      # Model response cards
│       │   └── timeline.ex        # Timeline visualization
│       └── router.ex               # Route definitions
└── assets/                         # Frontend assets
    ├── css/
    │   └── app.css                # Tailwind CSS
    └── js/
        ├── app.js
        └── hooks/                  # LiveView hooks
            ├── chart_hook.js      # Chart rendering
            └── timeline_hook.js   # Timeline interactions
```

## 🧪 Mock System

All examples use a **sophisticated mock system** that simulates realistic LLM behavior:

### Mock Models
- **GPT-4**: High accuracy (94%), expensive ($0.005/query), medium latency
- **Claude-3**: High accuracy (93%), medium cost ($0.003/query), fast
- **Gemini-Pro**: Good accuracy (90%), cheap ($0.001/query), medium latency
- **Llama-3**: Decent accuracy (87%), very cheap ($0.0002/query), fast
- **Mixtral**: Good accuracy (89%), cheap ($0.0008/query), medium latency

### Realistic Simulation
- **Latency distributions**: P50/P95/P99 modeled after real-world data
- **Tail latency**: Occasional slow requests (10% of queries)
- **Response variation**: Models disagree ~15% of the time
- **Cost tracking**: Accurate per-model pricing
- **Error injection**: Rare failures (<1%) for robustness testing

## 🎨 Technologies Used

- **Phoenix Framework**: Web application framework
- **Phoenix LiveView**: Real-time, server-rendered UI
- **Tailwind CSS**: Utility-first styling
- **Contex**: Elixir charting library
- **Crucible Framework**: Statistical testing and LLM reliability tools

## 📚 Learning Resources

### Crucible Framework Documentation
- [Crucible Bench](../crucible_bench) - Statistical testing framework
- [Crucible Ensemble](../crucible_ensemble) - Multi-model voting
- [Crucible Hedging](../crucible_hedging) - Tail latency reduction
- [Crucible Trace](../crucible_trace) - Causal reasoning traces
- [Crucible Telemetry](../crucible_telemetry) - Research-grade instrumentation
- [Crucible Harness](../crucible_harness) - Experiment orchestration

### Example Use Cases
Each demo includes:
- **Scenario description**: Real-world context
- **What it demonstrates**: Key framework features
- **How it works**: Technical explanation
- **Try it yourself**: Interactive controls

## 🔧 Development

### Running Tests
```bash
# Run all tests
mix test

# Run specific test file
mix test test/crucible_examples/mock/models_test.exs

# Run with coverage
mix test --cover
```

**Test Suite**: 85 comprehensive tests covering:
- Mock system (Models, Latency, Datasets, Pricing) - 80 tests
- Web controllers and views - 5 tests
- All tests passing with zero warnings

### Running Examples

The `examples/` directory contains runnable scripts demonstrating each feature:

```bash
# Mock system demonstrations
mix run examples/mock_models_demo.exs
mix run examples/latency_demo.exs
mix run examples/datasets_demo.exs

# Interactive demo scripts
mix run examples/ensemble_demo.exs
mix run examples/hedging_demo.exs
mix run examples/stats_demo.exs
```

Each example script:
- Runs independently without the web server
- Demonstrates core framework capabilities
- Produces detailed console output
- Can be used for testing and benchmarking

### Code Formatting
```bash
mix format
```

### Building for Production
```bash
mix assets.deploy
MIX_ENV=prod mix release
```

## 🌐 Deployment

This project can be deployed to:
- **Fly.io**: `fly launch` (recommended)
- **Heroku**: Standard Phoenix deployment
- **Gigalixir**: Elixir-optimized platform
- **Docker**: Included Dockerfile

## 🤝 Contributing

This is a demonstration project for the Crucible Framework. Contributions welcome:

1. Fork the repository
2. Create a feature branch
3. Add new demo scenarios or improve existing ones
4. Submit a pull request

## 📄 License

MIT License - see [LICENSE](../LICENSE) for details

## 🙏 Acknowledgments

Built with:
- [Crucible Framework](https://github.com/north-shore-ai/crucible-framework) - Scientific LLM evaluation
- [Phoenix Framework](https://phoenixframework.org/) - Productive web framework
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/) - Real-time experiences

---

**Ready to explore?** Start the server with `mix phx.server` and visit [localhost:4000](http://localhost:4000)
