defmodule CrucibleExamples.Scenarios.TraceDemo do
  @moduledoc """
  Scenario: Causal Trace Explorer for LLM Reasoning Transparency

  Demonstrates how causal tracing reveals the decision-making process of LLMs
  through interactive timeline visualization showing:
  - Task decomposition steps
  - Hypothesis formation and testing
  - Pattern recognition insights
  - Decision points with alternatives
  - Constraint checking
  - Uncertainty estimation
  - Final synthesis

  Shows reasoning chains for complex problems across multiple domains:
  - Mathematical problem solving
  - Medical diagnosis reasoning
  - Code debugging analysis
  - Business strategy planning
  """

  @doc """
  Generate a complete reasoning trace for a given problem.

  Returns a map containing:
  - problem: The original problem description
  - domain: Problem domain (math, medical, code, business)
  - events: List of reasoning events with timestamps, types, descriptions, confidence, and alternatives
  - metadata: Summary statistics about the trace
  """
  def generate_trace(problem_id) do
    problem = get_problem(problem_id)
    events = generate_events(problem_id)

    %{
      problem_id: problem_id,
      problem: problem,
      events: events,
      metadata: calculate_metadata(events),
      generated_at: DateTime.utc_now()
    }
  end

  @doc """
  Get all available problems.
  """
  def list_problems do
    [
      %{
        id: 1,
        title: "Complex Math Problem",
        domain: "mathematics",
        difficulty: "hard",
        description:
          "A train leaves Station A at 60 mph. Another train leaves Station B (300 miles away) at 40 mph, heading toward Station A. If a bird flies at 80 mph between the trains until they meet, how far does the bird travel?"
      },
      %{
        id: 2,
        title: "Medical Diagnosis",
        domain: "medical",
        difficulty: "expert",
        description:
          "Patient: 45F with fatigue, weight loss (15 lbs/3 months), heat intolerance, palpitations, fine tremor. TSH: 0.1 mIU/L, Free T4: 3.2 ng/dL. What is the diagnosis and treatment plan?"
      },
      %{
        id: 3,
        title: "Code Debugging",
        domain: "engineering",
        difficulty: "medium",
        description:
          "A React component re-renders infinitely. The useEffect hook fetches data and updates state. The dependency array includes the entire state object. Why does this happen and how to fix it?"
      },
      %{
        id: 4,
        title: "Business Strategy",
        domain: "business",
        difficulty: "hard",
        description:
          "A SaaS company has 10,000 users, $50/month ARPU, 5% monthly churn, $200 CAC. Should they focus on retention (reduce churn to 3%) or acquisition (double new signups)? Analyze 12-month impact."
      }
    ]
  end

  @doc """
  Search events by type within a trace.
  """
  def filter_events(trace, event_type) do
    Map.update!(trace, :events, fn events ->
      Enum.filter(events, &(&1.type == event_type))
    end)
  end

  @doc """
  Export trace to JSON-serializable format.
  """
  def export_trace(trace) do
    trace
    |> Map.update!(:generated_at, &DateTime.to_iso8601/1)
    |> Map.update!(:events, fn events ->
      Enum.map(events, fn event ->
        Map.update!(event, :timestamp, &DateTime.to_iso8601/1)
      end)
    end)
  end

  # Private functions

  defp get_problem(problem_id) do
    list_problems()
    |> Enum.find(fn p -> p.id == problem_id end)
  end

  defp generate_events(1) do
    # Math problem: Bird flying between trains
    base_time = DateTime.utc_now()

    [
      %{
        id: 1,
        timestamp: DateTime.add(base_time, 0, :millisecond),
        type: :task_decomposition,
        title: "Problem Analysis",
        description:
          "Breaking down the problem: Two trains moving toward each other, bird flying between them. Need to find total bird distance.",
        confidence: 0.95,
        alternatives: [],
        reasoning:
          "Initial decomposition identifies three moving objects and one unknown (bird distance). Key insight: bird stops when trains meet.",
        uncertainty_factors: ["Bird behavior assumption", "Constant speeds"]
      },
      %{
        id: 2,
        timestamp: DateTime.add(base_time, 1200, :millisecond),
        type: :hypothesis_formation,
        title: "Initial Hypothesis",
        description:
          "Hypothesis: Calculate when trains meet, then multiply by bird's speed to get distance.",
        confidence: 0.85,
        alternatives: [
          "Track each bird leg individually (complex)",
          "Use relative velocity formula (elegant)"
        ],
        reasoning:
          "Multiple approaches possible. Time-based calculation is most straightforward. Alternative approaches noted for completeness.",
        uncertainty_factors: ["Approach efficiency"]
      },
      %{
        id: 3,
        timestamp: DateTime.add(base_time, 2400, :millisecond),
        type: :pattern_recognition,
        title: "Pattern Identified",
        description: "Recognized as a 'meeting time' problem - standard physics/algebra pattern.",
        confidence: 0.92,
        alternatives: [],
        reasoning:
          "This matches the classic pattern: two objects approaching, find meeting time. Formula: distance / (speed1 + speed2)",
        uncertainty_factors: []
      },
      %{
        id: 4,
        timestamp: DateTime.add(base_time, 3600, :millisecond),
        type: :decision_point,
        title: "Choose Solution Method",
        description:
          "Decision: Use relative velocity approach for trains, then bird distance = time × speed.",
        confidence: 0.88,
        alternatives: [
          %{
            option: "Track bird's zigzag path",
            pros: "More detailed",
            cons: "Infinite series, complex",
            confidence: 0.30
          },
          %{
            option: "Relative velocity method",
            pros: "Simple, elegant",
            cons: "Less intuitive",
            confidence: 0.88
          },
          %{
            option: "Simulation approach",
            pros: "Visual",
            cons: "Approximate only",
            confidence: 0.40
          }
        ],
        reasoning:
          "Relative velocity chosen: simplest and exact. Other methods either too complex or approximate.",
        uncertainty_factors: ["Method comprehension by audience"]
      },
      %{
        id: 5,
        timestamp: DateTime.add(base_time, 4800, :millisecond),
        type: :constraint_check,
        title: "Verify Constraints",
        description:
          "Checking: Trains actually meet, speeds are constant, bird flies continuously.",
        confidence: 0.90,
        alternatives: [],
        reasoning:
          "All constraints satisfied: combined speed (100 mph) ensures meeting, problem states constant speeds, bird behavior defined.",
        uncertainty_factors: []
      },
      %{
        id: 6,
        timestamp: DateTime.add(base_time, 6000, :millisecond),
        type: :calculation,
        title: "Calculate Meeting Time",
        description: "Time to meet = 300 miles / (60 + 40) mph = 300 / 100 = 3 hours",
        confidence: 0.98,
        alternatives: [],
        reasoning: "Straightforward division: total distance by combined approach speed.",
        uncertainty_factors: []
      },
      %{
        id: 7,
        timestamp: DateTime.add(base_time, 7200, :millisecond),
        type: :calculation,
        title: "Calculate Bird Distance",
        description: "Bird distance = 80 mph × 3 hours = 240 miles",
        confidence: 0.98,
        alternatives: [],
        reasoning:
          "Bird flies for entire 3-hour period at constant 80 mph. Simple distance = speed × time.",
        uncertainty_factors: []
      },
      %{
        id: 8,
        timestamp: DateTime.add(base_time, 8400, :millisecond),
        type: :verification,
        title: "Sanity Check",
        description:
          "Verification: Bird distance (240 mi) < total train distance (300 mi). Reasonable.",
        confidence: 0.95,
        alternatives: [],
        reasoning:
          "Result makes physical sense: bird can't travel more than the gap between trains. Proportions correct.",
        uncertainty_factors: []
      },
      %{
        id: 9,
        timestamp: DateTime.add(base_time, 9600, :millisecond),
        type: :uncertainty_estimation,
        title: "Assess Confidence",
        description:
          "High confidence (95%+) in answer. Math is straightforward, no ambiguous interpretations.",
        confidence: 0.96,
        alternatives: [],
        reasoning:
          "Standard problem type, clear constraints, verified calculation. Main uncertainty is problem interpretation.",
        uncertainty_factors: ["Implicit assumptions about bird behavior"]
      },
      %{
        id: 10,
        timestamp: DateTime.add(base_time, 10800, :millisecond),
        type: :synthesis,
        title: "Final Answer",
        description: "The bird travels 240 miles before the trains meet.",
        confidence: 0.96,
        alternatives: [],
        reasoning:
          "Combined all steps: meeting time (3 hours) × bird speed (80 mph) = 240 miles. Verified and confident.",
        uncertainty_factors: []
      }
    ]
  end

  defp generate_events(2) do
    # Medical diagnosis
    base_time = DateTime.utc_now()

    [
      %{
        id: 1,
        timestamp: DateTime.add(base_time, 0, :millisecond),
        type: :task_decomposition,
        title: "Clinical Data Review",
        description:
          "Breaking down patient presentation: demographics (45F), symptoms (fatigue, weight loss, tremor), and lab results (TSH, T4).",
        confidence: 0.92,
        alternatives: [],
        reasoning:
          "Systematic review of history, physical findings, and diagnostics. Pattern suggests endocrine disorder.",
        uncertainty_factors: ["Incomplete history", "Single lab timepoint"]
      },
      %{
        id: 2,
        timestamp: DateTime.add(base_time, 1500, :millisecond),
        type: :pattern_recognition,
        title: "Symptom Constellation",
        description:
          "Classic hyperthyroid pattern: weight loss, heat intolerance, palpitations, tremor, anxiety.",
        confidence: 0.88,
        alternatives: [],
        reasoning:
          "Multiple symptoms align with hypermetabolic state. High specificity for thyroid dysfunction.",
        uncertainty_factors: ["Symptom overlap with anxiety disorders"]
      },
      %{
        id: 3,
        timestamp: DateTime.add(base_time, 3000, :millisecond),
        type: :hypothesis_formation,
        title: "Primary Hypotheses",
        description:
          "Leading diagnosis: Hyperthyroidism. Differential includes Graves' disease, toxic adenoma, thyroiditis.",
        confidence: 0.85,
        alternatives: [
          "Graves' disease (autoimmune, most common)",
          "Toxic multinodular goiter",
          "Subacute thyroiditis",
          "TSH-secreting pituitary adenoma (rare)"
        ],
        reasoning:
          "Low TSH + elevated T4 confirms primary hyperthyroidism. Now need to identify specific etiology.",
        uncertainty_factors: ["Need imaging/antibody tests for definitive diagnosis"]
      },
      %{
        id: 4,
        timestamp: DateTime.add(base_time, 4500, :millisecond),
        type: :constraint_check,
        title: "Lab Value Analysis",
        description:
          "TSH 0.1 mIU/L (normal: 0.4-4.0), Free T4 3.2 ng/dL (normal: 0.8-1.8). Clear hyperthyroidism.",
        confidence: 0.94,
        alternatives: [],
        reasoning:
          "Suppressed TSH with elevated T4 definitively indicates primary hyperthyroidism. No lab assay error likely.",
        uncertainty_factors: ["Medication interference (biotin, amiodarone)"]
      },
      %{
        id: 5,
        timestamp: DateTime.add(base_time, 6000, :millisecond),
        type: :decision_point,
        title: "Most Likely Etiology",
        description:
          "Given age and presentation, Graves' disease is most probable (60-80% of hyperthyroid cases).",
        confidence: 0.78,
        alternatives: [
          %{
            option: "Graves' disease",
            pros: "Most common, fits demographics",
            cons: "Need TSI/TRAb confirmation",
            confidence: 0.78
          },
          %{
            option: "Toxic adenoma",
            pros: "Possible at this age",
            cons: "Usually older patients",
            confidence: 0.15
          },
          %{
            option: "Thyroiditis",
            pros: "Can present similarly",
            cons: "Usually transient symptoms",
            confidence: 0.12
          }
        ],
        reasoning:
          "Graves' most common in women 30-50. Would benefit from TSI antibodies, thyroid uptake scan for confirmation.",
        uncertainty_factors: ["Lack of antibody results", "No imaging yet"]
      },
      %{
        id: 6,
        timestamp: DateTime.add(base_time, 7500, :millisecond),
        type: :additional_workup,
        title: "Recommended Tests",
        description:
          "Order: TSI/TRAb antibodies, thyroid uptake scan, consider thyroid ultrasound. Check CBC, CMP.",
        confidence: 0.90,
        alternatives: [],
        reasoning:
          "Antibodies confirm Graves', scan shows uptake pattern, ultrasound identifies nodules. CBC/CMP assess baseline.",
        uncertainty_factors: []
      },
      %{
        id: 7,
        timestamp: DateTime.add(base_time, 9000, :millisecond),
        type: :decision_point,
        title: "Treatment Strategy",
        description:
          "Initial management: beta-blocker (symptom control) + antithyroid drug (methimazole or PTU).",
        confidence: 0.82,
        alternatives: [
          %{
            option: "Methimazole + beta-blocker",
            pros: "Standard first-line, once daily",
            cons: "Teratogenic (check pregnancy)",
            confidence: 0.82
          },
          %{
            option: "PTU + beta-blocker",
            pros: "Safe in pregnancy",
            cons: "Liver toxicity risk, TID dosing",
            confidence: 0.70
          },
          %{
            option: "Radioactive iodine",
            pros: "Definitive",
            cons: "Too early, need diagnosis confirmation",
            confidence: 0.40
          },
          %{
            option: "Surgery",
            pros: "Definitive",
            cons: "Reserved for specific cases",
            confidence: 0.20
          }
        ],
        reasoning:
          "Medical management preferred initially. Methimazole unless pregnant/planning pregnancy. Beta-blocker for symptoms.",
        uncertainty_factors: ["Pregnancy status unknown", "Patient preference"]
      },
      %{
        id: 8,
        timestamp: DateTime.add(base_time, 10500, :millisecond),
        type: :constraint_check,
        title: "Safety Considerations",
        description:
          "Check pregnancy test, baseline LFTs, CBC before starting treatment. Counsel on medication risks.",
        confidence: 0.95,
        alternatives: [],
        reasoning:
          "Methimazole contraindicated in pregnancy. Need baseline labs to monitor treatment. Inform about agranulocytosis risk.",
        uncertainty_factors: []
      },
      %{
        id: 9,
        timestamp: DateTime.add(base_time, 12000, :millisecond),
        type: :uncertainty_estimation,
        title: "Diagnostic Confidence",
        description:
          "85% confident in hyperthyroidism diagnosis, 75% in Graves' as etiology pending confirmatory tests.",
        confidence: 0.85,
        alternatives: [],
        reasoning:
          "Labs clearly show hyperthyroidism. Graves' most likely but need antibodies for confirmation. Treatment safe to start.",
        uncertainty_factors: ["Awaiting antibody results", "Rare causes not ruled out"]
      },
      %{
        id: 10,
        timestamp: DateTime.add(base_time, 13500, :millisecond),
        type: :synthesis,
        title: "Clinical Plan",
        description:
          "Diagnosis: Primary hyperthyroidism, likely Graves' disease. Plan: Start methimazole 10-20mg daily + propranolol 20-40mg TID. Order TSI, uptake scan. Follow-up 2-4 weeks for labs.",
        confidence: 0.85,
        alternatives: [],
        reasoning:
          "Evidence-based approach: confirm diagnosis, initiate treatment, monitor response. Adjust based on confirmatory tests.",
        uncertainty_factors: ["Individual patient response variability"]
      },
      %{
        id: 11,
        timestamp: DateTime.add(base_time, 15000, :millisecond),
        type: :monitoring,
        title: "Follow-up Strategy",
        description:
          "Monitor TSH, Free T4 every 4-6 weeks initially. Watch for medication side effects. Consider definitive therapy (RAI/surgery) if medical management fails.",
        confidence: 0.88,
        alternatives: [],
        reasoning:
          "Standard monitoring protocol. Most patients respond to medical management. Definitive options available if needed.",
        uncertainty_factors: ["Treatment adherence", "Disease severity"]
      }
    ]
  end

  defp generate_events(3) do
    # Code debugging
    base_time = DateTime.utc_now()

    [
      %{
        id: 1,
        timestamp: DateTime.add(base_time, 0, :millisecond),
        type: :task_decomposition,
        title: "Problem Statement",
        description:
          "Analyzing React infinite render loop. Component: useEffect with data fetching, state update, state object in dependencies.",
        confidence: 0.93,
        alternatives: [],
        reasoning:
          "Clear problem description: infinite renders caused by useEffect. Need to identify root cause.",
        uncertainty_factors: ["Exact component code not provided"]
      },
      %{
        id: 2,
        timestamp: DateTime.add(base_time, 1200, :millisecond),
        type: :pattern_recognition,
        title: "Classic React Anti-pattern",
        description:
          "Recognized common mistake: entire object in dependency array causes new reference each render.",
        confidence: 0.95,
        alternatives: [],
        reasoning:
          "This is a well-documented React pitfall. Objects/arrays are compared by reference, not value.",
        uncertainty_factors: []
      },
      %{
        id: 3,
        timestamp: DateTime.add(base_time, 2400, :millisecond),
        type: :hypothesis_formation,
        title: "Root Cause Hypothesis",
        description:
          "State object reference changes every render → useEffect sees 'new' dependency → runs again → updates state → new reference → infinite loop.",
        confidence: 0.92,
        alternatives: ["Async timing issue", "Multiple state updates batching problem"],
        reasoning:
          "Dependency array comparison uses Object.is() which checks reference equality. State updates create new objects.",
        uncertainty_factors: []
      },
      %{
        id: 4,
        timestamp: DateTime.add(base_time, 3600, :millisecond),
        type: :decision_point,
        title: "Solution Approach",
        description: "Need to break the dependency cycle. Multiple solutions possible.",
        confidence: 0.88,
        alternatives: [
          %{
            option: "Use specific state properties",
            pros: "Most common fix, explicit dependencies",
            cons: "Need to identify which properties",
            confidence: 0.88
          },
          %{
            option: "Empty dependency array",
            pros: "Simple",
            cons: "Stale closure issues",
            confidence: 0.40
          },
          %{
            option: "useRef for latest state",
            pros: "Avoids re-runs",
            cons: "More complex pattern",
            confidence: 0.60
          },
          %{
            option: "Custom deep comparison hook",
            pros: "Compares values not references",
            cons: "Performance overhead, complexity",
            confidence: 0.50
          }
        ],
        reasoning:
          "Best practice: depend on specific primitive values. Avoid entire objects. Clear, performant, maintainable.",
        uncertainty_factors: ["Specific component requirements"]
      },
      %{
        id: 5,
        timestamp: DateTime.add(base_time, 4800, :millisecond),
        type: :constraint_check,
        title: "React Rules Verification",
        description:
          "Checking: useEffect dependency array should include all used values. But primitives only, not objects.",
        confidence: 0.94,
        alternatives: [],
        reasoning:
          "React exhaustive-deps linting rule enforces this. Primitives (strings, numbers) compared by value are safe.",
        uncertainty_factors: []
      },
      %{
        id: 6,
        timestamp: DateTime.add(base_time, 6000, :millisecond),
        type: :solution_design,
        title: "Recommended Fix",
        description:
          "Replace [stateObject] with [stateObject.specificProperty] or extract needed primitives before useEffect.",
        confidence: 0.90,
        alternatives: [],
        reasoning:
          "If effect needs stateObject.id, depend on that. If needs multiple, list each. Primitives don't change reference.",
        uncertainty_factors: ["Unknown which properties are actually needed"]
      },
      %{
        id: 7,
        timestamp: DateTime.add(base_time, 7200, :millisecond),
        type: :verification,
        title: "Alternative Validation",
        description:
          "Consider: Could also use useMemo to memoize derived values, or useCallback for fetch function.",
        confidence: 0.85,
        alternatives: [],
        reasoning:
          "useMemo/useCallback can help, but fixing dependency array is root solution. Memoization is optimization.",
        uncertainty_factors: []
      },
      %{
        id: 8,
        timestamp: DateTime.add(base_time, 8400, :millisecond),
        type: :code_example,
        title: "Code Pattern",
        description:
          "Instead of: useEffect(() => { fetch().then(setData) }, [state]) → Use: useEffect(() => { fetch().then(setData) }, [state.id])",
        confidence: 0.92,
        alternatives: [],
        reasoning:
          "Concrete example shows the fix. Depend on primitive state.id instead of entire state object.",
        uncertainty_factors: []
      },
      %{
        id: 9,
        timestamp: DateTime.add(base_time, 9600, :millisecond),
        type: :uncertainty_estimation,
        title: "Confidence Assessment",
        description:
          "90% confident this is the issue and fix. High confidence due to classic pattern match.",
        confidence: 0.90,
        alternatives: [],
        reasoning:
          "Pattern is extremely common in React. Fix is well-established. Only uncertainty is specific component details.",
        uncertainty_factors: [
          "Exact component implementation unknown",
          "Possible multiple issues"
        ]
      },
      %{
        id: 10,
        timestamp: DateTime.add(base_time, 10800, :millisecond),
        type: :synthesis,
        title: "Complete Solution",
        description:
          "Problem: Object reference in dependency array. Solution: Use primitive dependencies. Prevention: Enable eslint-plugin-react-hooks. Testing: Verify renders stabilize.",
        confidence: 0.90,
        alternatives: [],
        reasoning:
          "Comprehensive answer addresses root cause, solution, prevention, and verification. Standard React best practice.",
        uncertainty_factors: []
      }
    ]
  end

  defp generate_events(4) do
    # Business strategy
    base_time = DateTime.utc_now()

    [
      %{
        id: 1,
        timestamp: DateTime.add(base_time, 0, :millisecond),
        type: :task_decomposition,
        title: "Problem Setup",
        description:
          "SaaS metrics analysis: 10K users, $50 ARPU, 5% churn, $200 CAC. Compare retention vs acquisition strategies over 12 months.",
        confidence: 0.94,
        alternatives: [],
        reasoning:
          "Well-defined financial problem. Need to model both scenarios and compare outcomes. Clear metrics provided.",
        uncertainty_factors: ["Market conditions", "Execution capability"]
      },
      %{
        id: 2,
        timestamp: DateTime.add(base_time, 1500, :millisecond),
        type: :pattern_recognition,
        title: "Unit Economics Pattern",
        description:
          "Classic SaaS unit economics decision: improve LTV through retention or accelerate growth through acquisition.",
        confidence: 0.90,
        alternatives: [],
        reasoning:
          "Both strategies have trade-offs. Retention improves LTV/CAC ratio. Acquisition drives top-line growth.",
        uncertainty_factors: ["Company stage and goals matter"]
      },
      %{
        id: 3,
        timestamp: DateTime.add(base_time, 3000, :millisecond),
        type: :calculation,
        title: "Baseline Metrics",
        description:
          "Current state: Monthly revenue = 10,000 × $50 = $500K. Annual revenue = $6M. Monthly lost customers = 500 (5% churn).",
        confidence: 0.96,
        alternatives: [],
        reasoning:
          "Straightforward calculations from given metrics. Establishes baseline for comparison.",
        uncertainty_factors: []
      },
      %{
        id: 4,
        timestamp: DateTime.add(base_time, 4500, :millisecond),
        type: :hypothesis_formation,
        title: "Scenario Modeling",
        description:
          "Scenario A: Reduce churn 5%→3% (retain 200 more users/month). Scenario B: Double acquisition (same 5% churn).",
        confidence: 0.88,
        alternatives: [],
        reasoning:
          "Need to model cohort dynamics. Churn reduction has compounding effect. Acquisition is linear growth.",
        uncertainty_factors: [
          "Assumes strategies are mutually exclusive",
          "Cost of implementation"
        ]
      },
      %{
        id: 5,
        timestamp: DateTime.add(base_time, 6000, :millisecond),
        type: :calculation,
        title: "Retention Scenario",
        description:
          "3% churn means 97% retention. Month 12: ~11,500 users, $575K MRR. Saved ~1,800 customers over year.",
        confidence: 0.85,
        alternatives: [],
        reasoning:
          "Exponential model: users(t) = users(t-1) × 0.97 + new. Compounds monthly. Conservative estimate without growth.",
        uncertainty_factors: ["Assumes same acquisition continues", "Churn reduction timing"]
      },
      %{
        id: 6,
        timestamp: DateTime.add(base_time, 7500, :millisecond),
        type: :calculation,
        title: "Acquisition Scenario",
        description:
          "Double new users but 5% still churn. Month 12: ~13,000 users, $650K MRR. But higher CAC spend.",
        confidence: 0.85,
        alternatives: [],
        reasoning:
          "Linear growth model with churn. Faster top-line growth but loses more customers in absolute terms.",
        uncertainty_factors: ["CAC may increase with volume", "Market saturation"]
      },
      %{
        id: 7,
        timestamp: DateTime.add(base_time, 9000, :millisecond),
        type: :decision_point,
        title: "Financial Analysis",
        description:
          "Acquisition shows higher revenue ($650K vs $575K) but retention has better unit economics and sustainability.",
        confidence: 0.80,
        alternatives: [
          %{
            option: "Focus on retention",
            pros: "Better LTV/CAC, sustainable, compounds, lower cost",
            cons: "Slower top-line growth",
            confidence: 0.82
          },
          %{
            option: "Focus on acquisition",
            pros: "Faster growth, market share, visibility",
            cons: "Higher CAC spend, leaky bucket, worse unit economics",
            confidence: 0.68
          },
          %{
            option: "Balanced approach",
            pros: "Mitigates risks",
            cons: "Resources spread thin",
            confidence: 0.70
          }
        ],
        reasoning:
          "Retention typically better for mature SaaS. Acquisition better for land-grab situations. Context matters.",
        uncertainty_factors: ["Company stage", "Funding situation", "Competitive landscape"]
      },
      %{
        id: 8,
        timestamp: DateTime.add(base_time, 10500, :millisecond),
        type: :constraint_check,
        title: "LTV/CAC Ratio Check",
        description:
          "Current LTV (simplified): $50 × (1/0.05) = $1,000. LTV/CAC = 5:1 (healthy). Retention improves this to ~7:1.",
        confidence: 0.88,
        alternatives: [],
        reasoning:
          "LTV = ARPU / churn rate (simplified). Industry standard is 3:1 minimum. Both scenarios maintain healthy ratio.",
        uncertainty_factors: ["Simplified LTV calculation", "Gross margin not factored"]
      },
      %{
        id: 9,
        timestamp: DateTime.add(base_time, 12000, :millisecond),
        type: :strategic_consideration,
        title: "Market Context",
        description:
          "If early-stage or land-grab market: acquisition. If mature product or limited budget: retention.",
        confidence: 0.75,
        alternatives: [],
        reasoning:
          "Strategy depends on company goals. Growth-stage prioritizes ARR growth. Efficient growth prioritizes unit economics.",
        uncertainty_factors: ["Company strategy not specified", "Market dynamics unknown"]
      },
      %{
        id: 10,
        timestamp: DateTime.add(base_time, 13500, :millisecond),
        type: :uncertainty_estimation,
        title: "Confidence Assessment",
        description:
          "Moderate confidence (75-80%). Financial models are clear but strategic choice depends on unstated context.",
        confidence: 0.78,
        alternatives: [],
        reasoning:
          "Math is solid. Retention objectively better for unit economics. But acquisition might be strategically necessary.",
        uncertainty_factors: ["Company goals", "Competitive pressure", "Funding runway"]
      },
      %{
        id: 11,
        timestamp: DateTime.add(base_time, 15000, :millisecond),
        type: :synthesis,
        title: "Recommendation",
        description:
          "Recommend: Retention focus (reduce churn to 3%). Better unit economics, compounds over time, more sustainable. Exception: if in land-grab market needing rapid share capture.",
        confidence: 0.80,
        alternatives: [],
        reasoning:
          "For most SaaS companies, fixing churn before scaling is optimal. Retention improvements compound. Avoid 'leaky bucket' problem.",
        uncertainty_factors: ["Specific company context"]
      },
      %{
        id: 12,
        timestamp: DateTime.add(base_time, 16500, :millisecond),
        type: :implementation,
        title: "Action Plan",
        description:
          "Steps: 1) Analyze churn cohorts, 2) Identify retention interventions, 3) A/B test improvements, 4) Monitor metrics, 5) Iterate. Maintain current acquisition while improving retention.",
        confidence: 0.82,
        alternatives: [],
        reasoning:
          "Practical implementation path. Data-driven approach. Doesn't require abandoning growth entirely.",
        uncertainty_factors: ["Team capacity", "Product maturity"]
      }
    ]
  end

  defp calculate_metadata(events) do
    total_events = length(events)
    event_types = events |> Enum.map(& &1.type) |> Enum.uniq()
    avg_confidence = events |> Enum.map(& &1.confidence) |> Enum.sum() |> Kernel./(total_events)

    decision_points =
      events |> Enum.filter(&(&1.type == :decision_point)) |> length()

    alternatives_considered =
      events
      |> Enum.map(&length(&1.alternatives))
      |> Enum.sum()

    %{
      total_events: total_events,
      event_types: event_types,
      decision_points: decision_points,
      alternatives_considered: alternatives_considered,
      avg_confidence: Float.round(avg_confidence, 3),
      duration_ms:
        DateTime.diff(List.last(events).timestamp, List.first(events).timestamp, :millisecond)
    }
  end
end
