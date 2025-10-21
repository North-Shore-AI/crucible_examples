defmodule CrucibleExamplesWeb.StatsLive do
  use CrucibleExamplesWeb, :live_view

  alias CrucibleExamples.Scenarios.StatsDemo
  alias CrucibleExamples.Mock.Models

  @impl true
  def mount(_params, _session, socket) do
    models = Models.all_models()

    socket =
      socket
      |> assign(page_title: "Statistical Comparison Lab")
      |> assign(models: models)
      |> assign(model_a_id: :gpt4)
      |> assign(model_b_id: :claude3)
      |> assign(sample_size: 25)
      |> assign(result: nil)
      |> assign(loading: false)
      |> assign(progress: 0)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_model_a", %{"model" => model_id}, socket) do
    {:noreply, assign(socket, model_a_id: String.to_existing_atom(model_id), result: nil)}
  end

  @impl true
  def handle_event("select_model_b", %{"model" => model_id}, socket) do
    {:noreply, assign(socket, model_b_id: String.to_existing_atom(model_id), result: nil)}
  end

  @impl true
  def handle_event("select_sample_size", %{"size" => size}, socket) do
    {:noreply, assign(socket, sample_size: String.to_integer(size), result: nil)}
  end

  @impl true
  def handle_event("run_comparison", _params, socket) do
    socket = assign(socket, loading: true, progress: 0)
    send(self(), :execute_comparison)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, result: nil, progress: 0)}
  end

  @impl true
  def handle_info(:execute_comparison, socket) do
    # Simulate progress updates
    send(self(), {:progress_update, 10})

    # Run the comparison
    result =
      StatsDemo.run_comparison(
        socket.assigns.model_a_id,
        socket.assigns.model_b_id,
        socket.assigns.sample_size,
        simulate_delay: true
      )

    send(self(), {:progress_update, 100})

    {:noreply, assign(socket, result: result, loading: false)}
  end

  @impl true
  def handle_info({:progress_update, value}, socket) do
    {:noreply, assign(socket, progress: value)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="mb-8">
          <.link navigate="/" class="text-indigo-600 hover:text-indigo-800 mb-4 inline-block">
            ← Back to Examples
          </.link>
          <h1 class="text-4xl font-bold text-gray-900 mb-2">
            Statistical Comparison Lab
          </h1>
          <p class="text-lg text-gray-600">
            A/B test two models with proper statistical rigor: t-tests, effect sizes, and confidence intervals
          </p>
        </div>
        
    <!-- Configuration Panel -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 class="text-2xl font-bold text-gray-900 mb-4">Experiment Configuration</h2>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Model A Selector -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Model A
              </label>
              <select
                phx-change="select_model_a"
                name="model"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
              >
                <%= for model <- @models do %>
                  <option value={model.id} selected={model.id == @model_a_id}>
                    {model.name} ({model.vendor})
                  </option>
                <% end %>
              </select>
              <%= if @model_a_id do %>
                <div class="mt-2 text-xs text-gray-600">
                  <p>Accuracy: {Float.round(Models.get_model(@model_a_id).accuracy * 100, 1)}%</p>
                  <p>Cost: ${Models.get_model(@model_a_id).cost_per_query}/query</p>
                </div>
              <% end %>
            </div>
            
    <!-- Model B Selector -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Model B
              </label>
              <select
                phx-change="select_model_b"
                name="model"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
              >
                <%= for model <- @models do %>
                  <option value={model.id} selected={model.id == @model_b_id}>
                    {model.name} ({model.vendor})
                  </option>
                <% end %>
              </select>
              <%= if @model_b_id do %>
                <div class="mt-2 text-xs text-gray-600">
                  <p>Accuracy: {Float.round(Models.get_model(@model_b_id).accuracy * 100, 1)}%</p>
                  <p>Cost: ${Models.get_model(@model_b_id).cost_per_query}/query</p>
                </div>
              <% end %>
            </div>
            
    <!-- Sample Size Selector -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Sample Size
              </label>
              <select
                phx-change="select_sample_size"
                name="size"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
              >
                <option value="10" selected={@sample_size == 10}>10 questions (quick)</option>
                <option value="25" selected={@sample_size == 25}>25 questions (recommended)</option>
                <option value="50" selected={@sample_size == 50}>50 questions (thorough)</option>
                <option value="100" selected={@sample_size == 100}>
                  100 questions (comprehensive)
                </option>
              </select>
              <div class="mt-2 text-xs text-gray-600">
                <p>Dataset: Math word problems</p>
                <p>Statistical power increases with sample size</p>
              </div>
            </div>
          </div>
          
    <!-- Run Button -->
          <div class="mt-6 space-y-2">
            <button
              phx-click="run_comparison"
              disabled={@loading || @model_a_id == @model_b_id}
              class="w-full px-6 py-3 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors text-lg font-semibold"
            >
              {if @loading, do: "Running Experiment...", else: "Run Statistical Comparison"}
            </button>

            <%= if @model_a_id == @model_b_id do %>
              <p class="text-sm text-red-600 text-center">
                Please select different models for comparison
              </p>
            <% end %>

            <%= if @result do %>
              <button
                phx-click="reset"
                class="w-full px-6 py-3 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors"
              >
                Reset
              </button>
            <% end %>
          </div>
          
    <!-- Progress Bar -->
          <%= if @loading && @progress > 0 do %>
            <div class="mt-4">
              <div class="flex items-center justify-between mb-1">
                <span class="text-sm text-gray-700">Progress</span>
                <span class="text-sm text-gray-700">{@progress}%</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-2">
                <div
                  class="bg-indigo-600 h-2 rounded-full transition-all duration-300"
                  style={"width: #{@progress}%"}
                >
                </div>
              </div>
            </div>
          <% end %>
        </div>
        
    <!-- Results Section -->
        <%= if @result do %>
          <.results_display result={@result} />
        <% end %>
      </div>
    </div>
    """
  end

  # Component: Results Display
  attr :result, :map, required: true

  defp results_display(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Winner Banner -->
      <.winner_banner result={@result} />
      
    <!-- Accuracy Comparison -->
      <.metric_comparison
        title="Accuracy Comparison"
        model_a={@result.model_a}
        model_b={@result.model_b}
        stats={@result.statistics.accuracy}
        metric_type="accuracy"
      />
      
    <!-- Latency Comparison -->
      <.metric_comparison
        title="Latency Comparison (P95)"
        model_a={@result.model_a}
        model_b={@result.model_b}
        stats={@result.statistics.latency}
        metric_type="latency"
      />
      
    <!-- Cost Comparison -->
      <.metric_comparison
        title="Cost per Query"
        model_a={@result.model_a}
        model_b={@result.model_b}
        stats={@result.statistics.cost}
        metric_type="cost"
      />
      
    <!-- Statistical Summary -->
      <.statistical_summary statistics={@result.statistics} />
      
    <!-- Report Summary -->
      <.report_summary result={@result} />
    </div>
    """
  end

  # Component: Winner Banner
  attr :result, :map, required: true

  defp winner_banner(assigns) do
    ~H"""
    <div class="bg-gradient-to-r from-indigo-500 to-purple-600 rounded-lg shadow-lg p-6 text-white">
      <h2 class="text-3xl font-bold mb-3">Experiment Results</h2>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="bg-white/10 rounded-lg p-4">
          <p class="text-sm opacity-90 mb-1">Accuracy Winner</p>
          <p class="text-xl font-bold">{@result.winner.accuracy_winner}</p>
        </div>
        <div class="bg-white/10 rounded-lg p-4">
          <p class="text-sm opacity-90 mb-1">Speed Winner</p>
          <p class="text-xl font-bold">{@result.winner.latency_winner}</p>
        </div>
        <div class="bg-white/10 rounded-lg p-4">
          <p class="text-sm opacity-90 mb-1">Cost Winner</p>
          <p class="text-xl font-bold">{@result.winner.cost_winner}</p>
        </div>
      </div>
      <div class="mt-4 pt-4 border-t border-white/20">
        <p class="text-sm opacity-90 mb-1">Overall Recommendation</p>
        <p class="text-lg font-semibold">{@result.winner.overall_recommendation}</p>
      </div>
    </div>
    """
  end

  # Component: Metric Comparison
  attr :title, :string, required: true
  attr :model_a, :map, required: true
  attr :model_b, :map, required: true
  attr :stats, :map, required: true
  attr :metric_type, :string, required: true

  defp metric_comparison(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-6">
      <h3 class="text-2xl font-bold text-gray-900 mb-4">{@title}</h3>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        <!-- Model A -->
        <div class="border-2 border-indigo-200 rounded-lg p-4">
          <h4 class="font-bold text-lg text-gray-900 mb-3">{@model_a.name}</h4>
          <.metric_display
            value={@stats.model_a.mean}
            ci_lower={@stats.model_a.ci_lower}
            ci_upper={@stats.model_a.ci_upper}
            metric_type={@metric_type}
          />
          <%= if @metric_type == "accuracy" do %>
            <p class="text-sm text-gray-600 mt-2">
              {@model_a.metrics.correct_count} / {@model_a.metrics.total_questions} correct
            </p>
          <% end %>
        </div>
        
    <!-- Model B -->
        <div class="border-2 border-purple-200 rounded-lg p-4">
          <h4 class="font-bold text-lg text-gray-900 mb-3">{@model_b.name}</h4>
          <.metric_display
            value={@stats.model_b.mean}
            ci_lower={@stats.model_b.ci_lower}
            ci_upper={@stats.model_b.ci_upper}
            metric_type={@metric_type}
          />
          <%= if @metric_type == "accuracy" do %>
            <p class="text-sm text-gray-600 mt-2">
              {@model_b.metrics.correct_count} / {@model_b.metrics.total_questions} correct
            </p>
          <% end %>
        </div>
      </div>
      
    <!-- Statistical Test Results -->
      <div class="bg-gray-50 rounded-lg p-4">
        <h4 class="font-semibold text-gray-900 mb-3">Statistical Test Results</h4>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
          <div>
            <p class="text-gray-600">Difference</p>
            <p class="font-mono font-bold text-gray-900">
              {format_value(@stats.difference.value, @metric_type)}
            </p>
            <p class="text-xs text-gray-500">
              95% CI: [{format_value(@stats.difference.ci_lower, @metric_type)}, {format_value(
                @stats.difference.ci_upper,
                @metric_type
              )}]
            </p>
          </div>
          <div>
            <p class="text-gray-600">p-value</p>
            <p class={"font-mono font-bold #{if @stats.statistically_significant, do: "text-green-600", else: "text-gray-600"}"}>
              {@stats.p_value}
            </p>
            <p class="text-xs text-gray-500">{@stats.significance}</p>
          </div>
          <div>
            <p class="text-gray-600">Effect Size (Cohen's d)</p>
            <p class={"font-mono font-bold #{if @stats.practically_significant, do: "text-green-600", else: "text-gray-600"}"}>
              {@stats.cohens_d}
            </p>
            <p class="text-xs text-gray-500">{@stats.effect_size_interpretation}</p>
          </div>
          <div>
            <p class="text-gray-600">Significance</p>
            <%= if @stats.statistically_significant do %>
              <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-green-100 text-green-800">
                Significant
              </span>
            <% else %>
              <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 text-gray-600">
                Not Significant
              </span>
            <% end %>
            <%= if @stats.practically_significant do %>
              <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-blue-100 text-blue-800 mt-1">
                Practical
              </span>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Component: Metric Display
  attr :value, :float, required: true
  attr :ci_lower, :float, required: true
  attr :ci_upper, :float, required: true
  attr :metric_type, :string, required: true

  defp metric_display(assigns) do
    ~H"""
    <div>
      <p class="text-3xl font-bold text-gray-900 mb-1">
        {format_value(@value, @metric_type)}
      </p>
      <p class="text-sm text-gray-600">
        95% CI: [{format_value(@ci_lower, @metric_type)}, {format_value(@ci_upper, @metric_type)}]
      </p>
      <div class="mt-2 relative">
        <div class="w-full bg-gray-200 rounded-full h-2">
          <div
            class="bg-indigo-600 h-2 rounded-full"
            style={"width: #{format_percentage(@value, @metric_type)}"}
          >
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Component: Statistical Summary
  attr :statistics, :map, required: true

  defp statistical_summary(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-6">
      <h3 class="text-2xl font-bold text-gray-900 mb-4">Statistical Summary</h3>

      <div class="prose max-w-none">
        <div class="bg-blue-50 border-l-4 border-blue-500 p-4 mb-4">
          <h4 class="font-semibold text-blue-900 mb-2">What do these statistics mean?</h4>
          <ul class="text-sm text-blue-800 space-y-1">
            <li>
              <strong>p-value:</strong>
              Probability of seeing this difference by chance. p &lt; 0.05 is considered statistically significant.
            </li>
            <li>
              <strong>Effect Size (Cohen's d):</strong>
              Magnitude of the difference. |d| &gt; 0.2 is practically meaningful.
            </li>
            <li>
              <strong>Confidence Interval:</strong>
              95% confident the true value lies within this range.
            </li>
            <li>
              <strong>Statistical vs Practical Significance:</strong>
              A result can be statistically significant but not practically meaningful (or vice versa).
            </li>
          </ul>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="bg-gray-50 rounded-lg p-4">
            <h5 class="font-semibold text-gray-900 mb-2">Accuracy</h5>
            <div class="space-y-1 text-sm">
              <.significance_badge stats={@statistics.accuracy} />
              <p class="text-gray-600">
                t({@statistics.accuracy.degrees_of_freedom}) = {@statistics.accuracy.t_statistic}
              </p>
            </div>
          </div>

          <div class="bg-gray-50 rounded-lg p-4">
            <h5 class="font-semibold text-gray-900 mb-2">Latency</h5>
            <div class="space-y-1 text-sm">
              <.significance_badge stats={@statistics.latency} />
              <p class="text-gray-600">
                t({@statistics.latency.degrees_of_freedom}) = {@statistics.latency.t_statistic}
              </p>
            </div>
          </div>

          <div class="bg-gray-50 rounded-lg p-4">
            <h5 class="font-semibold text-gray-900 mb-2">Cost</h5>
            <div class="space-y-1 text-sm">
              <.significance_badge stats={@statistics.cost} />
              <p class="text-gray-600">
                t({@statistics.cost.degrees_of_freedom}) = {@statistics.cost.t_statistic}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Component: Significance Badge
  attr :stats, :map, required: true

  defp significance_badge(assigns) do
    ~H"""
    <div class="flex gap-2 flex-wrap">
      <%= if @stats.statistically_significant do %>
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
          Stat. Sig.
        </span>
      <% else %>
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-600">
          Not Stat. Sig.
        </span>
      <% end %>
      <%= if @stats.practically_significant do %>
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
          Practical
        </span>
      <% end %>
    </div>
    """
  end

  # Component: Report Summary
  attr :result, :map, required: true

  defp report_summary(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-6">
      <h3 class="text-2xl font-bold text-gray-900 mb-4">Experiment Report</h3>

      <div class="bg-gray-50 rounded-lg p-4 font-mono text-sm">
        <pre class="whitespace-pre-wrap">
        ## A/B Test Results

        **Experiment:** {@result.model_a.name} vs {@result.model_b.name}
        **Dataset:** Math word problems (n={@result.sample_size})
        **Date:** {format_timestamp(@result.timestamp)}

        ### Results Summary

        **Accuracy:**
        - {@result.model_a.name}: {format_percentage_simple(@result.statistics.accuracy.model_a.mean)} (95% CI: {format_percentage_simple(@result.statistics.accuracy.model_a.ci_lower)}-{format_percentage_simple(@result.statistics.accuracy.model_a.ci_upper)})
        - {@result.model_b.name}: {format_percentage_simple(@result.statistics.accuracy.model_b.mean)} (95% CI: {format_percentage_simple(@result.statistics.accuracy.model_b.ci_lower)}-{format_percentage_simple(@result.statistics.accuracy.model_b.ci_upper)})
        - Difference: {format_percentage_simple(@result.statistics.accuracy.difference.value)} (p={@result.statistics.accuracy.p_value}, d={@result.statistics.accuracy.cohens_d})
        - {@result.statistics.accuracy.significance}

        **Latency (P95):**
        - {@result.model_a.name}: {Float.round(@result.statistics.latency.model_a.mean, 1)}ms
        - {@result.model_b.name}: {Float.round(@result.statistics.latency.model_b.mean, 1)}ms
        - Difference: {Float.round(@result.statistics.latency.difference.value, 1)}ms (p={@result.statistics.latency.p_value})

        **Cost:**
        - {@result.model_a.name}: ${Float.round(@result.statistics.cost.model_a.mean, 5)}/query
        - {@result.model_b.name}: ${Float.round(@result.statistics.cost.model_b.mean, 5)}/query
        - Difference: ${Float.round(@result.statistics.cost.difference.value, 5)} (p={@result.statistics.cost.p_value})

        ### Recommendation

        {@result.winner.overall_recommendation}
        </pre>
      </div>

      <div class="mt-4 flex gap-2">
        <button
          onclick="navigator.clipboard.writeText(this.previousElementSibling.querySelector('pre').textContent)"
          class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors text-sm"
        >
          Copy Report
        </button>
      </div>
    </div>
    """
  end

  # Helper functions

  defp format_value(value, "accuracy") do
    "#{Float.round(value * 100, 1)}%"
  end

  defp format_value(value, "latency") do
    "#{Float.round(value, 1)}ms"
  end

  defp format_value(value, "cost") do
    "$#{Float.round(value, 5)}"
  end

  defp format_value(value, _) do
    Float.round(value, 4)
  end

  defp format_percentage(value, "accuracy") do
    "#{min(Float.round(value * 100, 1), 100)}%"
  end

  defp format_percentage(value, "latency") do
    # Scale latency to percentage (assuming max 1000ms)
    "#{min(Float.round(value / 10, 1), 100)}%"
  end

  defp format_percentage(value, "cost") do
    # Scale cost to percentage (assuming max $0.01)
    "#{min(Float.round(value * 10000, 1), 100)}%"
  end

  defp format_percentage(_, _), do: "0%"

  defp format_percentage_simple(value) do
    "#{Float.round(value * 100, 1)}%"
  end

  defp format_timestamp(timestamp) do
    Calendar.strftime(timestamp, "%Y-%m-%d %H:%M:%S UTC")
  end
end
