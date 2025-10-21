defmodule CrucibleExamplesWeb.HedgingLive do
  use CrucibleExamplesWeb, :live_view

  alias CrucibleExamples.Scenarios.HedgingDemo

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Request Hedging Simulator")
      |> assign(queries: HedgingDemo.queries())
      |> assign(selected_query_id: 1)
      |> assign(hedging_strategy: :fixed)
      |> assign(delay_threshold: 1000)
      |> assign(latency_profile: :medium)
      |> assign(result: nil)
      |> assign(batch_result: nil)
      |> assign(loading: false)
      |> assign(mode: :single)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_query", %{"query_id" => query_id}, socket) do
    {:noreply, assign(socket, selected_query_id: String.to_integer(query_id), result: nil)}
  end

  @impl true
  def handle_event("select_strategy", %{"strategy" => strategy}, socket) do
    strategy_atom = String.to_existing_atom(strategy)

    # Calculate delay threshold for the new strategy
    delay_threshold =
      HedgingDemo.calculate_delay_threshold(
        strategy_atom,
        socket.assigns.latency_profile,
        fixed_delay_ms: socket.assigns.delay_threshold
      )

    {:noreply,
     assign(socket,
       hedging_strategy: strategy_atom,
       delay_threshold: delay_threshold,
       result: nil,
       batch_result: nil
     )}
  end

  @impl true
  def handle_event("update_delay", %{"delay" => delay}, socket) do
    delay_int = String.to_integer(delay)

    {:noreply, assign(socket, delay_threshold: delay_int, result: nil, batch_result: nil)}
  end

  @impl true
  def handle_event("select_profile", %{"profile" => profile}, socket) do
    profile_atom = String.to_existing_atom(profile)

    # Recalculate delay threshold for new profile
    delay_threshold =
      HedgingDemo.calculate_delay_threshold(
        socket.assigns.hedging_strategy,
        profile_atom,
        fixed_delay_ms: socket.assigns.delay_threshold
      )

    {:noreply,
     assign(socket,
       latency_profile: profile_atom,
       delay_threshold: delay_threshold,
       result: nil,
       batch_result: nil
     )}
  end

  @impl true
  def handle_event("run_single", _params, socket) do
    socket = assign(socket, loading: true, mode: :single)
    send(self(), :execute_single)
    {:noreply, socket}
  end

  @impl true
  def handle_event("run_batch", _params, socket) do
    socket = assign(socket, loading: true, mode: :batch)
    send(self(), :execute_batch)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, result: nil, batch_result: nil, mode: :single)}
  end

  @impl true
  def handle_info(:execute_single, socket) do
    # Run single hedged request
    result =
      HedgingDemo.run_hedging(
        socket.assigns.selected_query_id,
        socket.assigns.hedging_strategy,
        latency_profile: socket.assigns.latency_profile,
        fixed_delay_ms: socket.assigns.delay_threshold
      )

    {:noreply, assign(socket, result: result, loading: false)}
  end

  @impl true
  def handle_info(:execute_batch, socket) do
    # Run batch of 100 queries
    batch_result =
      HedgingDemo.run_batch(
        100,
        socket.assigns.hedging_strategy,
        latency_profile: socket.assigns.latency_profile,
        fixed_delay_ms: socket.assigns.delay_threshold
      )

    {:noreply, assign(socket, batch_result: batch_result, loading: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-purple-50 to-pink-100 py-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="mb-8">
          <.link navigate="/" class="text-purple-600 hover:text-purple-800 mb-4 inline-block">
            ← Back to Examples
          </.link>
          <h1 class="text-4xl font-bold text-gray-900 mb-2">
            ⚡ Request Hedging Simulator
          </h1>
          <p class="text-lg text-gray-600 mb-3">
            Customer support chatbot: Reduce tail latency by sending backup requests
          </p>
          <div class="bg-purple-50 border-l-4 border-purple-500 p-4 rounded">
            <p class="text-sm text-gray-700">
              <strong>What you'll see:</strong>
              Request hedging reduces tail latency (P99) by 50-75% with minimal cost overhead.
              When a request takes too long, we send a backup "hedge" request. Whichever completes first wins.
              This dramatically improves worst-case user experience with only 5-15% cost increase.
            </p>
          </div>
        </div>
        
    <!-- Configuration Panel -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 class="text-2xl font-bold text-gray-900 mb-4">Configuration</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <!-- Query Selector -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Select Query
              </label>
              <select
                phx-change="select_query"
                name="query_id"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              >
                <%= for q <- @queries do %>
                  <option value={q.id} selected={q.id == @selected_query_id}>
                    #{q.id} - {q.category}
                  </option>
                <% end %>
              </select>

              <%= if @selected_query_id do %>
                <div class="mt-4 p-4 bg-gray-50 rounded-md">
                  <p class="text-sm text-gray-700 font-medium mb-2">Query:</p>
                  <p class="text-sm text-gray-600">
                    {Enum.find(@queries, &(&1.id == @selected_query_id)).text}
                  </p>
                </div>
              <% end %>
            </div>
            
    <!-- Hedging Strategy -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Hedging Strategy
              </label>
              <select
                phx-change="select_strategy"
                name="strategy"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              >
                <option value="fixed" selected={@hedging_strategy == :fixed}>
                  Fixed Delay (1000ms)
                </option>
                <option value="percentile" selected={@hedging_strategy == :percentile}>
                  Percentile-based (P95)
                </option>
                <option value="adaptive" selected={@hedging_strategy == :adaptive}>
                  Adaptive (ML-based)
                </option>
              </select>

              <%= if @hedging_strategy == :fixed do %>
                <div class="mt-4">
                  <label class="block text-sm font-medium text-gray-700 mb-2">
                    Delay Threshold (ms)
                  </label>
                  <input
                    type="range"
                    phx-change="update_delay"
                    name="delay"
                    min="100"
                    max="3000"
                    step="100"
                    value={@delay_threshold}
                    class="w-full"
                  />
                  <div class="text-center text-sm text-gray-600 mt-1">
                    {@delay_threshold}ms
                  </div>
                </div>
              <% else %>
                <div class="mt-4 p-3 bg-purple-50 rounded-md">
                  <p class="text-sm text-gray-700">
                    <strong>Threshold:</strong> {@delay_threshold}ms
                  </p>
                  <p class="text-xs text-gray-500 mt-1">
                    Calculated from latency profile
                  </p>
                </div>
              <% end %>
            </div>
            
    <!-- Latency Profile -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Latency Profile
              </label>
              <select
                phx-change="select_profile"
                name="profile"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              >
                <option value="fast" selected={@latency_profile == :fast}>
                  Fast (P50=200ms, P99=2s)
                </option>
                <option value="medium" selected={@latency_profile == :medium}>
                  Medium (P50=500ms, P99=5s)
                </option>
                <option value="slow" selected={@latency_profile == :slow}>
                  Slow (P50=1s, P99=8s)
                </option>
              </select>

              <div class="mt-4 space-y-2">
                <button
                  phx-click="run_single"
                  disabled={@loading}
                  class="w-full px-6 py-3 bg-purple-600 text-white rounded-md hover:bg-purple-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                >
                  {if @loading and @mode == :single, do: "Running...", else: "Run Single Query"}
                </button>

                <button
                  phx-click="run_batch"
                  disabled={@loading}
                  class="w-full px-6 py-3 bg-pink-600 text-white rounded-md hover:bg-pink-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                >
                  {if @loading and @mode == :batch,
                    do: "Running...",
                    else: "Run Batch (100 queries)"}
                </button>

                <%= if @result || @batch_result do %>
                  <button
                    phx-click="reset"
                    class="w-full px-6 py-3 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors"
                  >
                    Reset
                  </button>
                <% end %>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Results Section -->
        <%= if @result do %>
          <.single_query_result result={@result} />
        <% end %>

        <%= if @batch_result do %>
          <.batch_results result={@batch_result} />
        <% end %>
      </div>
    </div>
    """
  end

  # Component: Single Query Result
  attr :result, :map, required: true

  defp single_query_result(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Winner Banner -->
      <div class={"rounded-lg p-6 #{winner_banner_class(@result.winner)}"}>
        <div class="flex items-center justify-between">
          <div>
            <h3 class="text-2xl font-bold text-gray-900 mb-2">
              {winner_emoji(@result.winner)} {winner_text(@result.winner)}
            </h3>
            <p class="text-lg text-gray-700">
              Total Latency: <strong>{@result.total_latency}ms</strong>
            </p>
            <%= if @result.hedge_fired do %>
              <p class="text-sm text-gray-600 mt-1">
                Latency saved: {@result.latency_saved}ms
              </p>
            <% end %>
          </div>
          <div class="text-right">
            <p class="text-3xl font-bold text-gray-900">
              {@result.cost_multiplier}x
            </p>
            <p class="text-sm text-gray-600">Cost</p>
          </div>
        </div>
      </div>
      
    <!-- Latency Timeline -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Latency Timeline</h3>
        <.latency_timeline result={@result} />
      </div>
      
    <!-- Request Details -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Request Details</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="space-y-3">
            <div class="p-4 bg-blue-50 rounded-lg">
              <h4 class="font-semibold text-blue-900 mb-2">Primary Request</h4>
              <p class="text-sm text-gray-700">
                <strong>Latency:</strong> {@result.primary_latency}ms
              </p>
              <p class="text-sm text-gray-700">
                <strong>Status:</strong>
                {if @result.winner in [:primary_won, :primary_fast], do: "Won", else: "Lost"}
              </p>
            </div>
          </div>

          <div class="space-y-3">
            <%= if @result.hedge_fired do %>
              <div class="p-4 bg-purple-50 rounded-lg">
                <h4 class="font-semibold text-purple-900 mb-2">Hedge Request</h4>
                <p class="text-sm text-gray-700">
                  <strong>Fired at:</strong> {@result.delay_threshold}ms
                </p>
                <p class="text-sm text-gray-700">
                  <strong>Total Latency:</strong> {@result.hedge_latency}ms
                </p>
                <p class="text-sm text-gray-700">
                  <strong>Status:</strong> {if @result.winner == :hedge_won, do: "Won", else: "Lost"}
                </p>
              </div>
            <% else %>
              <div class="p-4 bg-gray-50 rounded-lg">
                <h4 class="font-semibold text-gray-700 mb-2">Hedge Request</h4>
                <p class="text-sm text-gray-600">
                  Not fired (primary completed in {@result.primary_latency}ms)
                </p>
                <p class="text-sm text-gray-500 mt-1">
                  Threshold: {@result.delay_threshold}ms
                </p>
              </div>
            <% end %>
          </div>
        </div>

        <div class="mt-4 p-4 bg-gray-50 rounded-lg">
          <h4 class="font-semibold text-gray-700 mb-2">Configuration</h4>
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span class="text-gray-600">Strategy:</span>
              <span class="font-mono ml-2">{@result.strategy}</span>
            </div>
            <div>
              <span class="text-gray-600">Delay Threshold:</span>
              <span class="font-mono ml-2">{@result.delay_threshold}ms</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Component: Latency Timeline
  attr :result, :map, required: true

  defp latency_timeline(assigns) do
    # Calculate timeline visualization
    max_time = max(assigns.result.primary_latency, assigns.result.hedge_latency || 0)

    assigns =
      assigns
      |> assign(:max_time, max_time)
      |> assign(:primary_width, assigns.result.primary_latency / max_time * 100)
      |> assign(
        :hedge_start_width,
        if(assigns.result.hedge_fired,
          do: assigns.result.delay_threshold / max_time * 100,
          else: 0
        )
      )
      |> assign(
        :hedge_duration_width,
        if(assigns.result.hedge_fired,
          do: (assigns.result.hedge_latency - assigns.result.delay_threshold) / max_time * 100,
          else: 0
        )
      )

    ~H"""
    <div class="space-y-4">
      <div class="text-sm text-gray-600 mb-2">
        Timeline scale: 0ms to {@max_time}ms
      </div>
      
    <!-- Primary Request Bar -->
      <div>
        <div class="flex items-center mb-1">
          <span class="text-sm font-medium text-gray-700 w-32">Primary Request</span>
        </div>
        <div class="relative h-8 bg-gray-100 rounded">
          <div
            class={"absolute h-8 bg-blue-500 rounded flex items-center justify-end pr-2 #{if @result.winner in [:primary_won, :primary_fast], do: "ring-4 ring-green-300", else: ""}"}
            style={"width: #{@primary_width}%"}
          >
            <span class="text-xs text-white font-bold">{@result.primary_latency}ms</span>
          </div>
        </div>
      </div>
      
    <!-- Hedge Request Bar -->
      <%= if @result.hedge_fired do %>
        <div>
          <div class="flex items-center mb-1">
            <span class="text-sm font-medium text-gray-700 w-32">Hedge Request</span>
          </div>
          <div class="relative h-8 bg-gray-100 rounded">
            <!-- Waiting period (transparent) -->
            <div
              class="absolute h-8 bg-transparent border-l-2 border-dashed border-purple-400"
              style={"width: #{@hedge_start_width}%; left: 0"}
            >
            </div>
            <!-- Hedge execution -->
            <div
              class={"absolute h-8 bg-purple-500 rounded-r flex items-center justify-end pr-2 #{if @result.winner == :hedge_won, do: "ring-4 ring-green-300", else: ""}"}
              style={"width: #{@hedge_duration_width}%; left: #{@hedge_start_width}%"}
            >
              <span class="text-xs text-white font-bold">{@result.hedge_latency}ms</span>
            </div>
          </div>
        </div>
      <% else %>
        <div>
          <div class="flex items-center mb-1">
            <span class="text-sm font-medium text-gray-700 w-32">Hedge Request</span>
          </div>
          <div class="relative h-8 bg-gray-100 rounded">
            <div class="absolute h-8 flex items-center pl-2">
              <span class="text-xs text-gray-500">Not fired</span>
            </div>
          </div>
        </div>
      <% end %>
      
    <!-- Winner indicator -->
      <div class="flex items-center justify-center mt-4 p-3 bg-green-50 rounded-lg">
        <span class="text-sm font-medium text-green-800">
          User received response in {@result.total_latency}ms
        </span>
      </div>
    </div>
    """
  end

  # Component: Batch Results
  attr :result, :map, required: true

  defp batch_results(assigns) do
    # Calculate histogram data
    baseline_histogram = HedgingDemo.calculate_histogram(assigns.result.baseline_latencies, 15)
    hedged_histogram = HedgingDemo.calculate_histogram(assigns.result.hedged_latencies, 15)

    assigns =
      assigns
      |> assign(:baseline_histogram, baseline_histogram)
      |> assign(:hedged_histogram, hedged_histogram)

    ~H"""
    <div class="space-y-6">
      <!-- Summary Banner -->
      <div class="bg-gradient-to-r from-green-50 to-blue-50 rounded-lg p-6 border-2 border-green-500">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Batch Results Summary</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="text-center">
            <p class="text-4xl font-bold text-green-600">
              {Float.round(@result.improvement.p99_pct, 1)}%
            </p>
            <p class="text-sm text-gray-600 mt-1">P99 Improvement</p>
          </div>
          <div class="text-center">
            <p class="text-4xl font-bold text-blue-600">
              {Float.round(@result.hedge_stats.firing_rate * 100, 1)}%
            </p>
            <p class="text-sm text-gray-600 mt-1">Hedge Firing Rate</p>
          </div>
          <div class="text-center">
            <p class="text-4xl font-bold text-orange-600">
              {@result.hedge_stats.avg_cost_multiplier}x
            </p>
            <p class="text-sm text-gray-600 mt-1">Avg Cost</p>
          </div>
        </div>
      </div>
      
    <!-- Percentile Metrics Comparison -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Latency Percentiles</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Baseline -->
          <div class="p-4 bg-red-50 rounded-lg">
            <h4 class="font-semibold text-red-900 mb-3">Baseline (No Hedging)</h4>
            <div class="space-y-2 text-sm">
              <.percentile_row label="P50" value={@result.baseline.p50} color="gray" />
              <.percentile_row label="P95" value={@result.baseline.p95} color="orange" />
              <.percentile_row label="P99" value={@result.baseline.p99} color="red" />
              <.percentile_row label="Mean" value={@result.baseline.mean} color="gray" />
            </div>
          </div>
          
    <!-- Hedged -->
          <div class="p-4 bg-green-50 rounded-lg">
            <h4 class="font-semibold text-green-900 mb-3">With Hedging</h4>
            <div class="space-y-2 text-sm">
              <.percentile_row
                label="P50"
                value={@result.hedged.p50}
                improvement={@result.improvement.p50_pct}
                color="gray"
              />
              <.percentile_row
                label="P95"
                value={@result.hedged.p95}
                improvement={@result.improvement.p95_pct}
                color="orange"
              />
              <.percentile_row
                label="P99"
                value={@result.hedged.p99}
                improvement={@result.improvement.p99_pct}
                color="red"
              />
              <.percentile_row label="Mean" value={@result.hedged.mean} color="gray" />
            </div>
          </div>
        </div>
      </div>
      
    <!-- Latency Histogram -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Latency Distribution</h3>
        <.histogram
          baseline={@baseline_histogram}
          hedged={@hedged_histogram}
          strategy={@result.strategy}
        />
      </div>
      
    <!-- Cost Analysis -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Cost Overhead Analysis</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="p-4 bg-gray-50 rounded-lg">
            <p class="text-sm text-gray-600 mb-1">Hedge Fired</p>
            <p class="text-3xl font-bold text-gray-900">
              {@result.hedge_stats.fired_count}/{@result.count}
            </p>
            <p class="text-xs text-gray-500 mt-1">
              {Float.round(@result.hedge_stats.firing_rate * 100, 1)}% of requests
            </p>
          </div>

          <div class="p-4 bg-orange-50 rounded-lg">
            <p class="text-sm text-orange-600 mb-1">Average Cost Multiplier</p>
            <p class="text-3xl font-bold text-orange-900">
              {@result.hedge_stats.avg_cost_multiplier}x
            </p>
            <p class="text-xs text-gray-500 mt-1">
              vs baseline (1.0x)
            </p>
          </div>

          <div class="p-4 bg-green-50 rounded-lg">
            <p class="text-sm text-green-600 mb-1">Cost Efficiency</p>
            <p class="text-3xl font-bold text-green-900">
              {calculate_cost_efficiency(@result)}%
            </p>
            <p class="text-xs text-gray-500 mt-1">
              Latency gain per cost unit
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Component: Percentile Row
  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :improvement, :any, default: nil
  attr :color, :string, default: "gray"

  defp percentile_row(assigns) do
    ~H"""
    <div class="flex justify-between items-center">
      <span class="text-gray-700 font-medium">{@label}:</span>
      <div class="flex items-center gap-2">
        <span class="font-mono">{round(@value)}ms</span>
        <%= if @improvement do %>
          <span class="text-xs text-green-600 font-semibold">
            (-{Float.round(@improvement, 1)}%)
          </span>
        <% end %>
      </div>
    </div>
    """
  end

  # Component: Histogram
  attr :baseline, :list, required: true
  attr :hedged, :list, required: true
  attr :strategy, :atom, required: true

  defp histogram(assigns) do
    # Find max count for scaling
    max_baseline =
      if Enum.empty?(assigns.baseline),
        do: 1,
        else: Enum.max_by(assigns.baseline, & &1.count).count

    max_hedged =
      if Enum.empty?(assigns.hedged), do: 1, else: Enum.max_by(assigns.hedged, & &1.count).count

    max_count = max(max_baseline, max_hedged)

    assigns = assign(assigns, :max_count, max_count)

    ~H"""
    <div class="space-y-6">
      <div class="text-sm text-gray-600">
        Distribution of latencies across 100 requests
      </div>
      
    <!-- Baseline Histogram -->
      <div>
        <h4 class="font-semibold text-gray-700 mb-2">Baseline (No Hedging)</h4>
        <div class="space-y-1">
          <%= for bucket <- @baseline do %>
            <div class="flex items-center gap-2">
              <div class="w-24 text-xs text-gray-600 text-right">
                {bucket.start}-{bucket.end}
              </div>
              <div class="flex-1 bg-gray-100 rounded h-6 relative">
                <div
                  class="absolute h-6 bg-red-400 rounded flex items-center justify-end pr-1"
                  style={"width: #{if @max_count > 0, do: bucket.count / @max_count * 100, else: 0}%"}
                >
                  <%= if bucket.count > 0 do %>
                    <span class="text-xs text-white font-semibold">{bucket.count}</span>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
      
    <!-- Hedged Histogram -->
      <div>
        <h4 class="font-semibold text-gray-700 mb-2">With Hedging ({@strategy})</h4>
        <div class="space-y-1">
          <%= for bucket <- @hedged do %>
            <div class="flex items-center gap-2">
              <div class="w-24 text-xs text-gray-600 text-right">
                {bucket.start}-{bucket.end}
              </div>
              <div class="flex-1 bg-gray-100 rounded h-6 relative">
                <div
                  class="absolute h-6 bg-green-500 rounded flex items-center justify-end pr-1"
                  style={"width: #{if @max_count > 0, do: bucket.count / @max_count * 100, else: 0}%"}
                >
                  <%= if bucket.count > 0 do %>
                    <span class="text-xs text-white font-semibold">{bucket.count}</span>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # Helper functions

  defp winner_banner_class(winner) do
    case winner do
      :primary_fast -> "bg-blue-100 border-2 border-blue-500"
      :primary_won -> "bg-blue-100 border-2 border-blue-500"
      :hedge_won -> "bg-purple-100 border-2 border-purple-500"
      _ -> "bg-gray-100 border-2 border-gray-500"
    end
  end

  defp winner_emoji(winner) do
    case winner do
      :primary_fast -> "⚡"
      :primary_won -> "🏆"
      :hedge_won -> "🎯"
      _ -> "❓"
    end
  end

  defp winner_text(winner) do
    case winner do
      :primary_fast -> "Primary Fast (Hedge Not Fired)"
      :primary_won -> "Primary Won"
      :hedge_won -> "Hedge Won"
      _ -> "Unknown"
    end
  end

  defp calculate_cost_efficiency(result) do
    # P99 improvement % / avg cost multiplier
    if result.hedge_stats.avg_cost_multiplier > 0 do
      efficiency = result.improvement.p99_pct / result.hedge_stats.avg_cost_multiplier
      Float.round(efficiency, 1)
    else
      0.0
    end
  end
end
