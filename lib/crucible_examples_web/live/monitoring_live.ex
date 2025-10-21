defmodule CrucibleExamplesWeb.MonitoringLive do
  use CrucibleExamplesWeb, :live_view

  alias CrucibleExamples.Scenarios.MonitoringDemo

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Production Monitoring Dashboard")
      |> assign(time_window: :days_30)
      |> assign(degraded: false)
      |> assign(monitoring_data: nil)
      |> assign(loading: false)
      |> assign(auto_refresh: false)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_time_window", %{"window" => window}, socket) do
    window_atom = String.to_existing_atom(window)
    {:noreply, assign(socket, time_window: window_atom, monitoring_data: nil)}
  end

  @impl true
  def handle_event("toggle_degradation", _params, socket) do
    new_degraded = !socket.assigns.degraded
    {:noreply, assign(socket, degraded: new_degraded, monitoring_data: nil)}
  end

  @impl true
  def handle_event("run_analysis", _params, socket) do
    socket = assign(socket, loading: true)
    send(self(), :execute_analysis)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, monitoring_data: nil, degraded: false)}
  end

  @impl true
  def handle_info(:execute_analysis, socket) do
    # Simulate processing delay for realism
    Process.sleep(500)

    monitoring_data =
      MonitoringDemo.get_monitoring_data(
        socket.assigns.time_window,
        socket.assigns.degraded
      )

    {:noreply, assign(socket, monitoring_data: monitoring_data, loading: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-50 to-blue-100 py-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="mb-8">
          <.link navigate="/" class="text-blue-600 hover:text-blue-800 mb-4 inline-block">
            ← Back to Examples
          </.link>
          <h1 class="text-4xl font-bold text-gray-900 mb-2">
            Production Monitoring Dashboard
          </h1>
          <p class="text-lg text-gray-600">
            Continuous model health tracking with statistical degradation detection
          </p>
        </div>
        
    <!-- Configuration Panel -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 class="text-2xl font-bold text-gray-900 mb-4">Configuration</h2>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Time Window Selector -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Time Window
              </label>
              <select
                phx-change="select_time_window"
                name="window"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="day_24h" selected={@time_window == :day_24h}>
                  Last 24 Hours
                </option>
                <option value="days_7" selected={@time_window == :days_7}>
                  Last 7 Days
                </option>
                <option value="days_30" selected={@time_window == :days_30}>
                  Last 30 Days
                </option>
              </select>
            </div>
            
    <!-- Degradation Toggle -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Scenario
              </label>
              <button
                phx-click="toggle_degradation"
                class={"w-full px-4 py-2 rounded-md font-medium transition-colors #{if @degraded, do: "bg-red-600 text-white hover:bg-red-700", else: "bg-green-600 text-white hover:bg-green-700"}"}
              >
                {if @degraded, do: "Degraded Performance", else: "Normal Performance"}
              </button>
              <p class="text-xs text-gray-500 mt-1">
                Click to toggle between normal and degraded scenarios
              </p>
            </div>
            
    <!-- Actions -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Actions
              </label>
              <div class="space-y-2">
                <button
                  phx-click="run_analysis"
                  disabled={@loading}
                  class="w-full px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors font-medium"
                >
                  {if @loading, do: "Analyzing...", else: "Run Health Check"}
                </button>

                <%= if @monitoring_data do %>
                  <button
                    phx-click="reset"
                    class="w-full px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors font-medium"
                  >
                    Reset
                  </button>
                <% end %>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Results Section -->
        <%= if @monitoring_data do %>
          <.monitoring_results data={@monitoring_data} />
        <% end %>
      </div>
    </div>
    """
  end

  # Component: Monitoring Results
  attr :data, :map, required: true

  defp monitoring_results(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Alert Banner -->
      <.alert_banner analysis={@data.analysis} />
      
    <!-- Metrics Overview -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Current Metrics vs Baseline</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <.metric_card
            name="Accuracy"
            current={@data.current_data.accuracy}
            baseline={@data.analysis.baseline_stats.accuracy.mean}
            ci_lower={@data.analysis.baseline_stats.accuracy.confidence_interval.lower}
            ci_upper={@data.analysis.baseline_stats.accuracy.confidence_interval.upper}
            z_score={@data.analysis.z_scores.accuracy}
            change_pct={@data.analysis.percentage_changes.accuracy}
            degraded={@data.analysis.degradation_detected.accuracy}
            format={:percentage}
            lower_is_better={false}
          />

          <.metric_card
            name="Latency P95"
            current={@data.current_data.latency_p95}
            baseline={@data.analysis.baseline_stats.latency_p95.mean}
            ci_lower={@data.analysis.baseline_stats.latency_p95.confidence_interval.lower}
            ci_upper={@data.analysis.baseline_stats.latency_p95.confidence_interval.upper}
            z_score={@data.analysis.z_scores.latency_p95}
            change_pct={@data.analysis.percentage_changes.latency_p95}
            degraded={@data.analysis.degradation_detected.latency_p95}
            format={:milliseconds}
            lower_is_better={true}
          />

          <.metric_card
            name="Error Rate"
            current={@data.current_data.error_rate}
            baseline={@data.analysis.baseline_stats.error_rate.mean}
            ci_lower={@data.analysis.baseline_stats.error_rate.confidence_interval.lower}
            ci_upper={@data.analysis.baseline_stats.error_rate.confidence_interval.upper}
            z_score={@data.analysis.z_scores.error_rate}
            change_pct={@data.analysis.percentage_changes.error_rate}
            degraded={@data.analysis.degradation_detected.error_rate}
            format={:percentage}
            lower_is_better={true}
          />
        </div>
      </div>
      
    <!-- Time Series Chart -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">
          Accuracy Trend - {@data.time_window_label}
        </h3>
        <.accuracy_chart
          baseline_data={@data.baseline_data}
          current_data={@data.current_data}
          baseline_stats={@data.analysis.baseline_stats.accuracy}
        />
      </div>
      
    <!-- Statistical Analysis -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Statistical Analysis</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Z-Scores -->
          <div>
            <h4 class="font-semibold text-gray-700 mb-3">Z-Score Analysis</h4>
            <div class="space-y-3">
              <.z_score_bar
                metric="Accuracy"
                z_score={@data.analysis.z_scores.accuracy}
                degraded={@data.analysis.degradation_detected.accuracy}
              />
              <.z_score_bar
                metric="Latency P95"
                z_score={@data.analysis.z_scores.latency_p95}
                degraded={@data.analysis.degradation_detected.latency_p95}
              />
              <.z_score_bar
                metric="Error Rate"
                z_score={@data.analysis.z_scores.error_rate}
                degraded={@data.analysis.degradation_detected.error_rate}
              />
            </div>
            <div class="mt-4 p-3 bg-gray-50 rounded text-sm text-gray-600">
              <p class="font-medium mb-1">Z-Score Thresholds:</p>
              <p>± 1.5: Warning (90% confidence)</p>
              <p>± 2.0: Critical (95% confidence)</p>
            </div>
          </div>
          
    <!-- Retraining Decision -->
          <div>
            <h4 class="font-semibold text-gray-700 mb-3">Retraining Recommendation</h4>
            <div class={"p-6 rounded-lg text-center #{if @data.analysis.needs_retraining, do: "bg-red-50 border-2 border-red-500", else: "bg-green-50 border-2 border-green-500"}"}>
              <div class="text-6xl mb-4">
                {if @data.analysis.needs_retraining, do: "⚠️", else: "✅"}
              </div>
              <p class="text-2xl font-bold text-gray-900 mb-2">
                {if @data.analysis.needs_retraining,
                  do: "Retraining Required",
                  else: "No Action Needed"}
              </p>
              <p class="text-sm text-gray-600">
                {if @data.analysis.needs_retraining,
                  do: "Model performance has degraded significantly",
                  else: "Model performance is within acceptable range"}
              </p>
            </div>

            <div class="mt-4 space-y-2">
              <div class="flex items-center justify-between text-sm">
                <span class="text-gray-600">Alert Status:</span>
                <span class={"px-3 py-1 rounded-full font-medium #{alert_badge_class(@data.analysis.alert_status)}"}>
                  {String.upcase(to_string(@data.analysis.alert_status))}
                </span>
              </div>
              <div class="flex items-center justify-between text-sm">
                <span class="text-gray-600">Baseline Period:</span>
                <span class="font-mono">{@data.analysis.baseline_stats.sample_size} days</span>
              </div>
              <div class="flex items-center justify-between text-sm">
                <span class="text-gray-600">Current Date:</span>
                <span class="font-mono">{Date.to_string(@data.current_data.date)}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Component: Alert Banner
  attr :analysis, :map, required: true

  defp alert_banner(assigns) do
    ~H"""
    <div class={"rounded-lg p-6 #{alert_banner_class(@analysis.alert_status)}"}>
      <div class="flex items-start">
        <div class="flex-shrink-0 text-4xl mr-4">
          {alert_icon(@analysis.alert_status)}
        </div>
        <div class="flex-1">
          <h3 class="text-xl font-bold text-gray-900 mb-2">
            {alert_title(@analysis.alert_status)}
          </h3>
          <p class="text-gray-700">
            {@analysis.alert_message}
          </p>
        </div>
      </div>
    </div>
    """
  end

  # Component: Metric Card
  attr :name, :string, required: true
  attr :current, :any, required: true
  attr :baseline, :any, required: true
  attr :ci_lower, :any, required: true
  attr :ci_upper, :any, required: true
  attr :z_score, :any, required: true
  attr :change_pct, :any, required: true
  attr :degraded, :boolean, required: true
  attr :format, :atom, required: true
  attr :lower_is_better, :boolean, required: true

  defp metric_card(assigns) do
    ~H"""
    <div class={"p-6 rounded-lg border-2 #{if @degraded, do: "border-red-500 bg-red-50", else: "border-green-500 bg-green-50"}"}>
      <h4 class="text-sm font-medium text-gray-600 mb-2">{@name}</h4>

      <div class="mb-4">
        <div class="text-3xl font-bold text-gray-900">
          {format_value(@current, @format)}
        </div>
        <div class="text-sm text-gray-600 mt-1">
          Current Value
        </div>
      </div>

      <div class="space-y-2 text-sm">
        <div class="flex justify-between">
          <span class="text-gray-600">Baseline Mean:</span>
          <span class="font-mono">{format_value(@baseline, @format)}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-600">95% CI Range:</span>
          <span class="font-mono text-xs">
            {format_value(@ci_lower, @format)} - {format_value(@ci_upper, @format)}
          </span>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-600">Change:</span>
          <span class={"font-mono font-bold #{change_color(@change_pct, @lower_is_better)}"}>
            {if @change_pct > 0, do: "+", else: ""}{@change_pct}%
          </span>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-600">Z-Score:</span>
          <span class={"font-mono font-bold #{z_score_color(@z_score)}"}>
            {@z_score}
          </span>
        </div>
      </div>

      <div class="mt-4 pt-4 border-t border-gray-300">
        <span class={"px-3 py-1 rounded-full text-xs font-medium #{if @degraded, do: "bg-red-200 text-red-800", else: "bg-green-200 text-green-800"}"}>
          {if @degraded, do: "DEGRADED", else: "NORMAL"}
        </span>
      </div>
    </div>
    """
  end

  # Component: Accuracy Chart (Simple ASCII-style visualization)
  attr :baseline_data, :list, required: true
  attr :current_data, :map, required: true
  attr :baseline_stats, :map, required: true

  defp accuracy_chart(assigns) do
    ~H"""
    <div class="space-y-4">
      <!-- Chart Legend -->
      <div class="flex items-center justify-center space-x-6 text-sm">
        <div class="flex items-center">
          <div class="w-4 h-4 bg-blue-500 rounded mr-2"></div>
          <span>Baseline Data</span>
        </div>
        <div class="flex items-center">
          <div class="w-4 h-4 bg-blue-200 rounded mr-2"></div>
          <span>95% Confidence Band</span>
        </div>
        <div class="flex items-center">
          <div class="w-4 h-4 bg-red-500 rounded mr-2"></div>
          <span>Current Day</span>
        </div>
      </div>
      
    <!-- Simple Chart Visualization -->
      <div class="relative h-64 bg-gray-50 rounded-lg p-4">
        <div class="absolute inset-0 p-4">
          <!-- Y-axis labels -->
          <div class="absolute left-0 top-0 bottom-0 w-12 flex flex-col justify-between text-xs text-gray-600">
            <span>100%</span>
            <span>95%</span>
            <span>90%</span>
            <span>85%</span>
            <span>80%</span>
          </div>
          
    <!-- Chart area -->
          <div class="ml-12 h-full relative">
            <!-- Confidence band -->
            <div
              class="absolute left-0 right-0 bg-blue-200 opacity-30"
              style={"bottom: #{calc_position(@baseline_stats.confidence_interval.lower)}%; height: #{calc_height(@baseline_stats.confidence_interval.lower, @baseline_stats.confidence_interval.upper)}%"}
            >
            </div>
            
    <!-- Baseline mean line -->
            <div
              class="absolute left-0 right-0 border-t-2 border-blue-500 border-dashed"
              style={"bottom: #{calc_position(@baseline_stats.mean)}%"}
            >
            </div>
            
    <!-- Data points (simplified - show min, max, mean) -->
            <div
              class="absolute left-1/4 w-3 h-3 bg-blue-500 rounded-full transform -translate-x-1/2 -translate-y-1/2"
              style={"bottom: #{calc_position(@baseline_stats.min)}%"}
            >
            </div>
            <div
              class="absolute left-1/2 w-3 h-3 bg-blue-500 rounded-full transform -translate-x-1/2 -translate-y-1/2"
              style={"bottom: #{calc_position(@baseline_stats.mean)}%"}
            >
            </div>
            <div
              class="absolute left-3/4 w-3 h-3 bg-blue-500 rounded-full transform -translate-x-1/2 -translate-y-1/2"
              style={"bottom: #{calc_position(@baseline_stats.max)}%"}
            >
            </div>
            
    <!-- Current day marker -->
            <div
              class="absolute right-4 w-4 h-4 bg-red-500 rounded-full transform -translate-y-1/2 animate-pulse"
              style={"bottom: #{calc_position(@current_data.accuracy)}%"}
            >
            </div>
          </div>
          
    <!-- X-axis label -->
          <div class="absolute bottom-0 left-12 right-0 text-center text-xs text-gray-600 mt-2">
            Time →
          </div>
        </div>
      </div>
      
    <!-- Chart Statistics -->
      <div class="grid grid-cols-3 gap-4 text-center text-sm">
        <div class="p-3 bg-gray-100 rounded">
          <p class="text-gray-600">Baseline Mean</p>
          <p class="text-lg font-bold text-gray-900">
            {format_value(@baseline_stats.mean, :percentage)}
          </p>
        </div>
        <div class="p-3 bg-gray-100 rounded">
          <p class="text-gray-600">Std Deviation</p>
          <p class="text-lg font-bold text-gray-900">
            {format_value(@baseline_stats.std_dev, :percentage)}
          </p>
        </div>
        <div class="p-3 bg-red-100 rounded">
          <p class="text-gray-600">Current Value</p>
          <p class="text-lg font-bold text-gray-900">
            {format_value(@current_data.accuracy, :percentage)}
          </p>
        </div>
      </div>
    </div>
    """
  end

  # Component: Z-Score Bar
  attr :metric, :string, required: true
  attr :z_score, :any, required: true
  attr :degraded, :boolean, required: true

  defp z_score_bar(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-1">
        <span class="text-sm font-medium text-gray-700">{@metric}</span>
        <span class={"text-sm font-mono font-bold #{z_score_color(@z_score)}"}>
          {@z_score}
        </span>
      </div>
      <div class="relative h-8 bg-gray-200 rounded-lg overflow-hidden">
        <!-- Threshold markers -->
        <div class="absolute left-1/4 top-0 bottom-0 w-px bg-yellow-400"></div>
        <div class="absolute left-1/2 top-0 bottom-0 w-px bg-red-400"></div>
        <div class="absolute right-1/4 top-0 bottom-0 w-px bg-yellow-400"></div>
        
    <!-- Z-score indicator -->
        <div
          class={"absolute top-0 bottom-0 w-1 #{if @degraded, do: "bg-red-600", else: "bg-green-600"}"}
          style={"left: #{z_score_position(@z_score)}%"}
        >
        </div>
        
    <!-- Center line -->
        <div class="absolute left-1/2 top-0 bottom-0 w-px bg-gray-400"></div>
      </div>
      <div class="flex justify-between text-xs text-gray-500 mt-1">
        <span>-3</span>
        <span>0</span>
        <span>+3</span>
      </div>
    </div>
    """
  end

  # Helper Functions

  defp format_value(value, :percentage) do
    "#{Float.round(value * 100, 2)}%"
  end

  defp format_value(value, :milliseconds) do
    "#{round(value)}ms"
  end

  defp alert_banner_class(:normal), do: "bg-green-100 border-2 border-green-500"
  defp alert_banner_class(:warning), do: "bg-yellow-100 border-2 border-yellow-500"
  defp alert_banner_class(:critical), do: "bg-red-100 border-2 border-red-500"

  defp alert_badge_class(:normal), do: "bg-green-200 text-green-800"
  defp alert_badge_class(:warning), do: "bg-yellow-200 text-yellow-800"
  defp alert_badge_class(:critical), do: "bg-red-200 text-red-800"

  defp alert_icon(:normal), do: "✅"
  defp alert_icon(:warning), do: "⚠️"
  defp alert_icon(:critical), do: "🚨"

  defp alert_title(:normal), do: "System Healthy"
  defp alert_title(:warning), do: "Performance Warning"
  defp alert_title(:critical), do: "Critical Alert"

  defp change_color(change, true) when change < 0, do: "text-green-600"
  defp change_color(change, true) when change > 0, do: "text-red-600"
  defp change_color(change, false) when change > 0, do: "text-green-600"
  defp change_color(change, false) when change < 0, do: "text-red-600"
  defp change_color(_, _), do: "text-gray-600"

  defp z_score_color(z) when abs(z) > 2.0, do: "text-red-600"
  defp z_score_color(z) when abs(z) > 1.5, do: "text-yellow-600"
  defp z_score_color(_), do: "text-green-600"

  defp z_score_position(z) do
    # Map z-score (-3 to +3) to percentage (0 to 100)
    # Center is at 50%
    clamped_z = max(-3.0, min(3.0, z))
    50 + clamped_z / 3.0 * 50
  end

  defp calc_position(value) do
    # Map accuracy (0.8 to 1.0) to position (0% to 100%)
    min_val = 0.8
    max_val = 1.0
    clamped = max(min_val, min(max_val, value))
    (clamped - min_val) / (max_val - min_val) * 100
  end

  defp calc_height(lower, upper) do
    # Calculate height of confidence band
    abs(calc_position(upper) - calc_position(lower))
  end
end
