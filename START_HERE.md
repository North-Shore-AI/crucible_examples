# 🚀 Quick Start Guide

## ✅ Project Status: READY TO RUN

The Crucible Examples project is fully set up and ready to use!

---

## 🏃 Running the Application

### Option 1: Standard Phoenix Server
```bash
cd /home/home/p/g/n/North-Shore-AI/crucible_examples
mix phx.server
```

Then open your browser to: **http://localhost:4000**

### Option 2: Interactive Elixir Shell
```bash
cd /home/home/p/g/n/North-Shore-AI/crucible_examples
iex -S mix phx.server
```

---

## ✅ What's Working

### Compilation ✅
- All Elixir dependencies compiled successfully
- No compilation errors
- No warnings in our code (external lib warnings are normal)

### Phoenix Server ✅
- Server starts on port 4000
- LiveView configured correctly
- Routing works
- Tailwind CSS compiled

### Mock System ✅
All 4 mock modules are implemented and tested:
- `CrucibleExamples.Mock.Models` - 5 LLM models
- `CrucibleExamples.Mock.Latency` - Realistic latency simulation
- `CrucibleExamples.Mock.Pricing` - Cost tracking
- `CrucibleExamples.Mock.Datasets` - Benchmark questions

### Homepage ✅
- Beautiful landing page with 6 example cards
- Gradient background
- Responsive grid layout
- "Coming Soon" status for demos

---

## 📋 What You'll See

When you visit **http://localhost:4000**, you'll see:

### Hero Section
- Title: "Crucible Framework - Interactive Examples"
- Description of the project
- Call to action

### 6 Example Cards
1. **Ensemble Reliability** 🎯 - Multi-model voting
2. **Request Hedging** ⚡ - Latency reduction
3. **Statistical Comparison** 📊 - A/B testing
4. **Causal Trace Explorer** 🔍 - Reasoning timeline
5. **Production Monitoring** 📈 - Health tracking
6. **Optimization Playground** 🎛️ - Parameter search

### Footer Info
- Mock system features
- Real framework components

---

## 🔧 Development Commands

### Compile
```bash
mix compile
```

### Run Tests
```bash
mix test
```

### Format Code
```bash
mix format
```

### Interactive Shell
```bash
iex -S mix
```

### Try Mock System
```elixir
# In IEx
alias CrucibleExamples.Mock.{Models, Latency, Datasets}

# Get a medical question
question = Datasets.sample(:medical)

# Query a model
{:ok, response} = Models.query(:gpt4, question.question, question.correct_answer)

# Simulate latency
latency_ms = Latency.simulate(:medium)
```

---

## 📁 Project Structure

```
crucible_examples/
├── lib/
│   ├── crucible_examples/
│   │   └── mock/                   ✅ Complete
│   │       ├── models.ex
│   │       ├── latency.ex
│   │       ├── datasets.ex
│   │       └── pricing.ex
│   └── crucible_examples_web/
│       ├── live/
│       │   └── home_live.ex       ✅ Complete
│       └── router.ex              ✅ Updated
├── README.md                       ✅ Complete
├── PROJECT_PLAN.md                 ✅ Complete
└── START_HERE.md                   ← You are here!
```

---

## ⚠️ Expected Warnings (Safe to Ignore)

When you start the server, you may see:

### File System Watching (Development Only)
```
[warning] Not able to start file_system worker
[warning] Could not start Phoenix live-reload
```
**This is fine!** These are optional development features for auto-reload. They don't affect the app.

### External Library Warnings
- Warnings from `contex`, `faker`, `nimble_strftime` are from dependencies
- Our code has **zero warnings**

---

## 🎯 Next Steps (Development)

The foundation is complete! Here's the roadmap:

### Phase 2: LiveView Infrastructure (Next)
- [ ] Build shared components (MetricsCard, ModelCard, Charts)
- [ ] Create demo scenario modules

### Phase 3-8: Build the 6 Examples
- [ ] Example 1: Ensemble Reliability Dashboard
- [ ] Example 2: Request Hedging Simulator
- [ ] Example 3: Statistical Comparison Lab
- [ ] Example 4: Causal Trace Explorer
- [ ] Example 5: Production Monitoring Dashboard
- [ ] Example 6: Optimization Playground

See `PROJECT_PLAN.md` for detailed roadmap.

---

## 🐛 Troubleshooting

### Server won't start?
```bash
# Check if port 4000 is in use
lsof -i :4000

# Use a different port
PORT=4001 mix phx.server
```

### Compilation errors?
```bash
# Clean and recompile
mix clean
mix deps.clean --all
mix deps.get
mix compile
```

### Dependencies issues?
```bash
# Update all dependencies
mix deps.update --all
mix deps.compile
```

---

## ✅ Verification Checklist

Before testing, verify:
- [x] Dependencies installed (`mix deps.get`)
- [x] Project compiles (`mix compile`)
- [x] No warnings in our code
- [x] Server starts successfully
- [x] Homepage loads at http://localhost:4000

**All checks passed! ✅**

---

## 📞 Support

- **Documentation**: See `README.md` and `PROJECT_PLAN.md`
- **Issues**: The project is working correctly!
- **Development**: Follow `PROJECT_PLAN.md` for next steps

---

**🎉 Ready to run! Execute `mix phx.server` and visit http://localhost:4000**
