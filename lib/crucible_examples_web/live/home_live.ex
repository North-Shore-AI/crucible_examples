defmodule CrucibleExamplesWeb.HomeLive do
  use CrucibleExamplesWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Crucible Examples")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <!-- Hero Section -->
        <div class="text-center mb-16">
          <h1 class="text-5xl font-bold text-gray-900 mb-4">
            Crucible Framework
          </h1>
          <p class="text-2xl text-indigo-600 mb-6">
            Interactive Examples
          </p>
          <p class="text-lg text-gray-600 max-w-3xl mx-auto">
            Experience ensemble voting, request hedging, statistical analysis, and more
            through beautiful, real-time visualizations. All running with mock LLMs—no API keys required.
          </p>
        </div>
        
    <!-- Example Cards Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <!-- Example 1: Ensemble -->
          <.demo_card
            title="Ensemble Reliability"
            description="Watch 5 models vote on medical diagnoses. See how ensemble voting achieves 96-99% reliability vs 89-92% single model."
            icon="🎯"
            status="Available"
            route={~p"/ensemble"}
          />
          
    <!-- Example 2: Hedging -->
          <.demo_card
            title="Request Hedging"
            description="Visualize tail latency reduction. See P99 improvements of 50-75% with minimal cost overhead."
            icon="⚡"
            status="Coming Soon"
            route={nil}
          />
          
    <!-- Example 3: Statistics -->
          <.demo_card
            title="Statistical Comparison"
            description="A/B test two models with proper statistical rigor. T-tests, effect sizes, and confidence intervals."
            icon="📊"
            status="Coming Soon"
            route={nil}
          />
          
    <!-- Example 4: Trace -->
          <.demo_card
            title="Causal Trace Explorer"
            description="Interactive timeline of LLM reasoning. Explore alternatives, track uncertainty, search event history."
            icon="🔍"
            status="Coming Soon"
            route={nil}
          />
          
    <!-- Example 5: Monitoring -->
          <.demo_card
            title="Production Monitoring"
            description="30-day health tracking with automated degradation detection. Statistical alerts and retraining triggers."
            icon="📈"
            status="Coming Soon"
            route={nil}
          />
          
    <!-- Example 6: Optimization -->
          <.demo_card
            title="Optimization Playground"
            description="Systematic parameter search with Bayesian optimization. Watch convergence in real-time."
            icon="🎛️"
            status="Coming Soon"
            route={nil}
          />
        </div>
        
    <!-- Footer Info -->
        <div class="mt-16 text-center">
          <div class="bg-white rounded-lg shadow-lg p-8 max-w-3xl mx-auto">
            <h3 class="text-2xl font-bold text-gray-900 mb-4">
              Mock LLMs + Real Framework
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 text-left">
              <div>
                <h4 class="font-semibold text-indigo-600 mb-2">Mock System</h4>
                <ul class="text-sm text-gray-600 space-y-1">
                  <li>✓ 5 realistic model profiles</li>
                  <li>✓ Accurate latency distributions</li>
                  <li>✓ Response variation (~15%)</li>
                  <li>✓ Cost tracking</li>
                </ul>
              </div>
              <div>
                <h4 class="font-semibold text-indigo-600 mb-2">Real Framework</h4>
                <ul class="text-sm text-gray-600 space-y-1">
                  <li>✓ Crucible Ensemble</li>
                  <li>✓ Crucible Hedging</li>
                  <li>✓ Crucible Bench (statistics)</li>
                  <li>✓ Crucible Trace</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Component for demo cards
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true
  attr :status, :string, default: "Available"
  attr :route, :any, default: nil

  defp demo_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 overflow-hidden">
      <div class="p-6">
        <div class="text-4xl mb-4">{@icon}</div>
        <h3 class="text-xl font-bold text-gray-900 mb-2">
          {@title}
        </h3>
        <p class="text-gray-600 text-sm mb-4 h-20">
          {@description}
        </p>
        <div class="flex items-center justify-between">
          <%= if @route do %>
            <.link
              navigate={@route}
              class="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
            >
              Try Demo →
            </.link>
          <% else %>
            <span class="inline-flex items-center px-4 py-2 bg-gray-300 text-gray-600 rounded-md cursor-not-allowed">
              {@status}
            </span>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
