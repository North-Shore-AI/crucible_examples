# Crucible Examples - Project Plan

**Status**: Foundation Complete ✅
**Created**: 2025-10-20
**Last Updated**: 2025-10-20

---

## 📋 Project Overview

### Vision
Build a Phoenix LiveView application that showcases the Crucible Framework's components through **mock LLM scenarios with real framework orchestration**. Users can experience ensemble voting, request hedging, statistical analysis, causal tracing, and production monitoring through beautiful, real-time visualizations.

### Key Innovation
- **Mock LLM calls** simulate realistic model responses, latency, and costs
- **Real Crucible Framework** orchestration, statistics, and analysis
- **No API keys required** - everything runs locally
- **Real-time visualization** of framework components in action

---

## 🎯 Interactive Examples (6 Total)

### 1. Ensemble Reliability Dashboard
**Scenario**: Medical diagnosis assistant with high-stakes decisions
**Status**: Not Started

**Features**:
- Watch 5 models respond to the same query
- See voting strategies (majority, weighted, unanimous) in action
- Real-time consensus metrics and confidence intervals
- Cost/accuracy trade-off visualization

**Mock Setup**:
- 5 models: GPT-4, Claude-3, Gemini-Pro, Llama-3, Mixtral
- Medical questions with intentional variation
- Models have different accuracy profiles (85%-95%)

---

### 2. Request Hedging Simulator
**Scenario**: Customer support chatbot with latency requirements
**Status**: Not Started

**Features**:
- Visualize tail latency reduction (P99 improvements)
- Compare hedging strategies (fixed, adaptive, percentile-based)
- Live latency histograms and firing indicators
- Cost efficiency metrics

**Mock Setup**:
- Realistic latency distribution (P50: 500ms, P95: 2000ms, P99: 5000ms)
- Mock "slow tail" queries (10% of requests)
- Hedging strategies: Fixed 1s delay, P95-based, adaptive

---

### 3. Statistical Comparison Lab
**Scenario**: A/B test comparing two models on math problems
**Status**: Not Started

**Features**:
- Configure experiment parameters
- Watch statistical analysis in real-time
- See t-tests, effect sizes, and confidence intervals
- Generate publication-ready reports

**Mock Setup**:
- 100 mock GSM8K-style math problems
- Model A: 87% accuracy, $0.002/query, 800ms avg
- Model B: 91% accuracy, $0.005/query, 600ms avg

---

### 4. Causal Trace Explorer
**Scenario**: Multi-step reasoning with decision transparency
**Status**: Not Started

**Features**:
- Interactive timeline of LLM reasoning process
- Explore alternatives considered at each step
- Uncertainty tracking over time
- Searchable event history

**Mock Setup**:
- Single LLM solving complex problem
- 10-15 reasoning steps with alternatives
- Mock causal trace events

---

### 5. Production Monitoring Dashboard
**Scenario**: Continuous model health monitoring
**Status**: Not Started

**Features**:
- 30-day historical baseline visualization
- Automated degradation detection with statistical tests
- Alert system based on confidence intervals
- Retraining trigger recommendations

**Mock Setup**:
- 30-day historical baseline data
- Current day with slight degradation (accuracy: 92% → 89%)
- Statistical monitoring with alerts

---

### 6. Optimization Playground
**Scenario**: Systematic prompt parameter search
**Status**: Not Started (Most Advanced)

**Features**:
- Define variable search spaces (temperature, tokens, examples)
- Choose optimization strategy (grid, random, Bayesian)
- Watch convergence in real-time
- Validate optimal configuration

**Mock Setup**:
- Variable space: temperature (0.0-2.0), max_tokens (100-2000), num_examples (0-10)
- Objective: maximize accuracy on 50 test queries
- Bayesian optimization with 30 trials

---

## ✅ Completed Work

### Phase 1: Foundation (Complete)

#### 1. Project Setup ✅
- [x] Generated Phoenix 1.8 LiveView project
- [x] Configured Crucible Framework dependencies
- [x] Set up directory structure
- [x] Created comprehensive README
- [x] Documented project plan

#### 2. Mock System ✅

**CrucibleExamples.Mock.Models** (`lib/crucible_examples/mock/models.ex`)
- [x] 5 realistic model profiles (GPT-4, Claude-3, Gemini-Pro, Llama-3, Mixtral)
- [x] Accuracy simulation (85%-94%)
- [x] Response variation (models disagree ~15%)
- [x] Error injection (1% failure rate)
- [x] Confidence score generation
- [x] Ensemble query simulation
- [x] Consensus analysis

**CrucibleExamples.Mock.Latency** (`lib/crucible_examples/mock/latency.ex`)
- [x] Three latency profiles (fast, medium, slow)
- [x] Realistic distributions (P50/P95/P99)
- [x] Tail latency simulation (10% slow requests)
- [x] Hedging scenario simulation
- [x] Latency distribution analysis
- [x] Batch simulation for histograms

**CrucibleExamples.Mock.Pricing** (`lib/crucible_examples/mock/pricing.ex`)
- [x] Per-query cost tracking
- [x] Ensemble cost calculation
- [x] Hedging cost calculation
- [x] Cost comparison utilities
- [x] Cost efficiency metrics
- [x] Experiment cost estimation

**CrucibleExamples.Mock.Datasets** (`lib/crucible_examples/mock/datasets.ex`)
- [x] Medical diagnosis questions (5 questions)
- [x] Math word problems (5 problems)
- [x] General knowledge (MMLU-style, 5 questions)
- [x] Code generation prompts (2 problems)
- [x] Category sampling
- [x] Batch generation

---

## 🚧 Next Steps

### Phase 2: LiveView Infrastructure (Week 1)

**Home Page**
- [ ] Create `HomeL Live` with hero section
- [ ] Build 6 scenario cards (ensemble, hedging, stats, trace, monitoring, optimization)
- [ ] Add navigation to each demo
- [ ] Design homepage layout

**Shared Components**
- [ ] `MetricsCard` component (display key metrics)
- [ ] `ModelCard` component (show model responses)
- [ ] `ChartContainer` component (wrapper for charts)
- [ ] Base layout with navigation

**Routing**
- [ ] Configure routes for all 6 demos
- [ ] Set up navigation bar
- [ ] Add breadcrumbs

---

### Phase 3: Example 1 - Ensemble Dashboard (Week 2)

**Backend**
- [ ] `CrucibleExamples.Scenarios.EnsembleDemo` module
- [ ] Integrate with Crucible.Ensemble
- [ ] Implement voting strategies
- [ ] Real-time consensus calculation

**Frontend**
- [ ] `EnsembleLive` LiveView module
- [ ] Model response cards (animated "thinking" state)
- [ ] Voting visualization (bar chart)
- [ ] Consensus meter
- [ ] Cost/latency/accuracy dashboard
- [ ] Single vs ensemble comparison

**Features**
- [ ] Query input form
- [ ] Strategy selector (majority, weighted, unanimous)
- [ ] Real-time updates as models respond
- [ ] Result history

---

### Phase 4: Example 2 - Hedging Simulator (Week 2)

**Backend**
- [ ] `CrucibleExamples.Scenarios.HedgingDemo` module
- [ ] Integrate with Crucible.Hedging
- [ ] Implement hedging strategies
- [ ] Latency tracking

**Frontend**
- [ ] `HedgingLive` LiveView module
- [ ] Latency distribution chart (histogram)
- [ ] Hedge firing indicator
- [ ] Before/after P99 comparison
- [ ] Cost efficiency meter
- [ ] Real-time query stream

**Features**
- [ ] Hedging strategy selector
- [ ] Delay threshold slider
- [ ] Batch query simulation (100 queries)
- [ ] Live metrics updates

---

### Phase 5: Example 3 - Statistical Comparison (Week 3)

**Backend**
- [ ] `CrucibleExamples.Scenarios.StatsDemo` module
- [ ] Integrate with Crucible.Bench
- [ ] Run statistical tests (t-test, effect sizes)
- [ ] Generate confidence intervals

**Frontend**
- [ ] `StatsLive` LiveView module
- [ ] Experiment configuration panel
- [ ] Progress tracker
- [ ] Accuracy comparison charts
- [ ] Statistical results panel
- [ ] Report preview (Markdown)

**Features**
- [ ] Model selector
- [ ] Sample size configuration
- [ ] Run experiment button
- [ ] Download report (Markdown/LaTeX/HTML)

---

### Phase 6: Example 4 - Causal Trace Explorer (Week 3)

**Backend**
- [ ] `CrucibleExamples.Scenarios.TraceDemo` module
- [ ] Integrate with Crucible.Trace
- [ ] Generate mock reasoning traces
- [ ] Event type simulation

**Frontend**
- [ ] `TraceLive` LiveView module
- [ ] Timeline visualization (horizontal scroll)
- [ ] Event detail panel
- [ ] Alternatives sidebar
- [ ] Uncertainty graph
- [ ] Search/filter

**Features**
- [ ] Click events to expand
- [ ] Show alternatives considered
- [ ] Confidence tracking
- [ ] Export to HTML

---

### Phase 7: Example 5 - Monitoring Dashboard (Week 4)

**Backend**
- [ ] `CrucibleExamples.Scenarios.MonitoringDemo` module
- [ ] Generate 30-day baseline data
- [ ] Simulate degradation
- [ ] Statistical degradation detection

**Frontend**
- [ ] `MonitoringLive` LiveView module
- [ ] Time-series chart (30 days)
- [ ] Baseline confidence band
- [ ] Alert indicators
- [ ] Statistical test panel
- [ ] Retraining recommendation

**Features**
- [ ] Live metrics simulation
- [ ] Alert threshold configuration
- [ ] Window size selector (1h, 6h, 24h)
- [ ] Metric breakdown

---

### Phase 8: Example 6 - Optimization Playground (Week 4)

**Backend**
- [ ] `CrucibleExamples.Scenarios.OptimizationDemo` module
- [ ] Define variable search space
- [ ] Implement optimization strategies
- [ ] Objective function

**Frontend**
- [ ] `OptimizationLive` LiveView module
- [ ] Variable space editor
- [ ] Strategy selector (grid, random, Bayesian)
- [ ] Optimization chart (best score vs trial)
- [ ] Configuration explorer (heatmap)
- [ ] Validation panel

**Features**
- [ ] Define custom variables
- [ ] Run optimization
- [ ] Watch convergence in real-time
- [ ] Validate optimal config
- [ ] Re-run with different settings

---

### Phase 9: Polish & Deploy (Week 5)

**UI/UX**
- [ ] Responsive design (mobile/tablet)
- [ ] Dark mode support
- [ ] Loading states
- [ ] Error handling
- [ ] Animations and transitions

**Documentation**
- [ ] Video demos for each example
- [ ] Screenshots for README
- [ ] Tutorial guides
- [ ] API documentation

**Deployment**
- [ ] Deploy to Fly.io
- [ ] Set up CI/CD
- [ ] Performance optimization
- [ ] Analytics (optional)

---

## 📁 File Structure

```
crucible_examples/
├── lib/
│   ├── crucible_examples/
│   │   ├── application.ex
│   │   ├── mock/                     ✅ COMPLETE
│   │   │   ├── models.ex            ✅ 5 models, accuracy, errors
│   │   │   ├── latency.ex           ✅ P50/P95/P99, tail latency
│   │   │   ├── datasets.ex          ✅ Medical, math, general, code
│   │   │   └── pricing.ex           ✅ Cost tracking, efficiency
│   │   ├── scenarios/                ⬜ TODO
│   │   │   ├── ensemble_demo.ex
│   │   │   ├── hedging_demo.ex
│   │   │   ├── stats_demo.ex
│   │   │   ├── trace_demo.ex
│   │   │   ├── monitoring_demo.ex
│   │   │   └── optimization_demo.ex
│   │   └── telemetry/                ⬜ TODO
│   │       ├── collector.ex
│   │       └── storage.ex
│   └── crucible_examples_web/
│       ├── live/                     ⬜ TODO
│       │   ├── home_live.ex
│       │   ├── ensemble_live.ex
│       │   ├── hedging_live.ex
│       │   ├── stats_live.ex
│       │   ├── trace_live.ex
│       │   ├── monitoring_live.ex
│       │   └── optimization_live.ex
│       ├── components/               ⬜ TODO
│       │   ├── charts.ex
│       │   ├── metrics_card.ex
│       │   ├── model_card.ex
│       │   └── timeline.ex
│       └── router.ex                 ⬜ TODO (update routes)
├── assets/
│   ├── css/
│   │   └── app.css
│   └── js/
│       ├── app.js
│       └── hooks/                    ⬜ TODO
│           ├── chart_hook.js
│           └── timeline_hook.js
├── README.md                         ✅ COMPLETE
├── PROJECT_PLAN.md                   ✅ COMPLETE
└── mix.exs                           ✅ COMPLETE (dependencies added)
```

---

## 🎨 Design Decisions

### Technology Stack
- **Backend**: Phoenix 1.8, Elixir 1.15+
- **Frontend**: Phoenix LiveView, Tailwind CSS
- **Charts**: Contex (Elixir-native charting)
- **Mock System**: Custom Elixir modules (no external APIs)

### Mock System Architecture
- **Deterministic mode**: Seeded randomness for reproducible demos
- **Realistic distributions**: Based on real-world LLM API data
- **Error injection**: 1% failure rate for robustness testing
- **Latency simulation**: P50/P95/P99 modeled after production data

### LiveView Strategy
- **Real-time updates**: PubSub for live metrics
- **Async tasks**: Background processing for simulations
- **Component-based**: Reusable UI components
- **State management**: LiveView assigns for demo state

---

## 📊 Success Metrics

### Technical
- [ ] All 6 examples functional
- [ ] <100ms LiveView update latency
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] Zero runtime errors

### Educational
- [ ] Clear explanations for each concept
- [ ] Interactive controls for exploration
- [ ] Visual feedback for all actions
- [ ] Export/download capabilities

### Adoption
- [ ] Deployed publicly (Fly.io)
- [ ] Documentation complete
- [ ] Video demos recorded
- [ ] Community feedback positive

---

## 🔄 Development Workflow

### Daily Cycle
1. Pick next feature from plan
2. Implement backend scenario logic
3. Build LiveView frontend
4. Test interactivity
5. Refine UI/UX
6. Update this plan

### Testing Strategy
- Unit tests for mock system
- Integration tests for scenarios
- LiveView tests for components
- Manual testing for UX

### Git Strategy
- Feature branches for each example
- PR reviews (self or peer)
- Main branch always deployable

---

## 📝 Notes

### Key Insights from Framework Review
1. **Crucible.Ensemble**: Supports 4 voting strategies, 4 execution strategies
2. **Crucible.Hedging**: Has fixed, percentile, adaptive, workload-aware strategies
3. **Crucible.Bench**: 15+ statistical tests, effect sizes, CIs
4. **Crucible.Trace**: 10 event types for reasoning transparency
5. **Crucible.Harness**: High-level DSL for experiment orchestration

### Implementation Priorities
1. **Ensemble** - Most visual, shows immediate value
2. **Hedging** - Demonstrates latency improvements clearly
3. **Stats** - Showcases scientific rigor
4. **Trace** - Unique transparency feature
5. **Monitoring** - Production relevance
6. **Optimization** - Advanced use case

---

**Last Updated**: 2025-10-20
**Next Session**: Start Phase 2 - LiveView Infrastructure
