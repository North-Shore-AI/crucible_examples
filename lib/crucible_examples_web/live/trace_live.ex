defmodule CrucibleExamplesWeb.TraceLive do
  use CrucibleExamplesWeb, :live_view

  alias CrucibleExamples.Scenarios.TraceDemo

  @impl true
  def mount(_params, _session, socket) do
    problems = TraceDemo.list_problems()

    socket =
      socket
      |> assign(page_title: "Causal Trace Explorer")
      |> assign(problems: problems)
      |> assign(selected_problem_id: 1)
      |> assign(trace: nil)
      |> assign(selected_event: nil)
      |> assign(event_filter: :all)
      |> assign(loading: false)
      |> assign(show_export: false)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_problem", %{"problem_id" => problem_id}, socket) do
    {:noreply,
     assign(socket,
       selected_problem_id: String.to_integer(problem_id),
       trace: nil,
       selected_event: nil
     )}
  end

  @impl true
  def handle_event("generate_trace", _params, socket) do
    socket = assign(socket, loading: true)
    send(self(), :execute_trace_generation)
    {:noreply, socket}
  end

  @impl true
  def handle_event("select_event", %{"event_id" => event_id}, socket) do
    event_id = String.to_integer(event_id)
    event = Enum.find(socket.assigns.trace.events, &(&1.id == event_id))
    {:noreply, assign(socket, selected_event: event)}
  end

  @impl true
  def handle_event("filter_events", %{"type" => type}, socket) do
    filter = if type == "all", do: :all, else: String.to_existing_atom(type)
    {:noreply, assign(socket, event_filter: filter, selected_event: nil)}
  end

  @impl true
  def handle_event("export_trace", _params, socket) do
    {:noreply, assign(socket, show_export: true)}
  end

  @impl true
  def handle_event("close_export", _params, socket) do
    {:noreply, assign(socket, show_export: false)}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, trace: nil, selected_event: nil, event_filter: :all)}
  end

  @impl true
  def handle_info(:execute_trace_generation, socket) do
    trace = TraceDemo.generate_trace(socket.assigns.selected_problem_id)
    {:noreply, assign(socket, trace: trace, loading: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-purple-50 to-indigo-100 py-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="mb-8">
          <.link navigate="/" class="text-indigo-600 hover:text-indigo-800 mb-4 inline-block">
            ← Back to Examples
          </.link>
          <h1 class="text-4xl font-bold text-gray-900 mb-2">
            🔍 Causal Trace Explorer
          </h1>
          <p class="text-lg text-gray-600 mb-3">
            Interactive timeline of LLM reasoning with decision transparency and uncertainty tracking
          </p>
          <div class="bg-purple-50 border-l-4 border-purple-500 p-4 rounded">
            <p class="text-sm text-gray-700">
              <strong>What you'll see:</strong>
              Explore the internal reasoning process of an LLM solving a complex problem.
              See every decision point, alternatives considered, and confidence levels throughout the reasoning chain.
              Essential for auditing, debugging, and understanding LLM decision-making.
            </p>
          </div>
        </div>
        
    <!-- Configuration Panel -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 class="text-2xl font-bold text-gray-900 mb-4">Configuration</h2>

          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Problem Selector -->
            <div class="lg:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Select Problem to Analyze
              </label>
              <select
                phx-change="select_problem"
                name="problem_id"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
              >
                <%= for p <- @problems do %>
                  <option value={p.id} selected={p.id == @selected_problem_id}>
                    {p.title} ({p.domain} - {p.difficulty})
                  </option>
                <% end %>
              </select>

              <%= if @selected_problem_id do %>
                <div class="mt-4 p-4 bg-gradient-to-r from-purple-50 to-indigo-50 rounded-md border border-indigo-200">
                  <p class="text-sm font-semibold text-indigo-900 mb-2">Problem Description:</p>
                  <p class="text-sm text-gray-700">
                    {Enum.find(@problems, &(&1.id == @selected_problem_id)).description}
                  </p>
                </div>
              <% end %>
            </div>
            
    <!-- Actions -->
            <div class="space-y-3">
              <button
                phx-click="generate_trace"
                disabled={@loading}
                class="w-full px-6 py-3 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors font-medium"
              >
                {if @loading, do: "Generating...", else: "Generate Reasoning Trace"}
              </button>

              <%= if @trace do %>
                <button
                  phx-click="export_trace"
                  class="w-full px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors font-medium"
                >
                  Export Trace JSON
                </button>

                <button
                  phx-click="reset"
                  class="w-full px-6 py-3 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors font-medium"
                >
                  Reset
                </button>
              <% end %>
            </div>
          </div>
        </div>
        
    <!-- Trace Results -->
        <%= if @trace do %>
          <!-- Metadata Summary -->
          <.trace_metadata metadata={@trace.metadata} problem={@trace.problem} />
          
    <!-- Event Filter -->
          <.event_filter filter={@event_filter} events={@trace.events} />
          
    <!-- Timeline Visualization -->
          <.timeline_visualization
            trace={@trace}
            selected_event={@selected_event}
            event_filter={@event_filter}
          />
          
    <!-- Event Detail Panel -->
          <%= if @selected_event do %>
            <.event_detail_panel event={@selected_event} />
          <% end %>
          
    <!-- Confidence Graph -->
          <.confidence_graph events={filtered_events(@trace.events, @event_filter)} />
        <% end %>
        
    <!-- Export Modal -->
        <%= if @show_export && @trace do %>
          <.export_modal trace={@trace} />
        <% end %>
      </div>
    </div>
    """
  end

  # Component: Trace Metadata
  attr :metadata, :map, required: true
  attr :problem, :map, required: true

  defp trace_metadata(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
      <h3 class="text-xl font-bold text-gray-900 mb-4">Trace Summary</h3>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="p-4 bg-indigo-50 rounded-lg">
          <p class="text-3xl font-bold text-indigo-900">{@metadata.total_events}</p>
          <p class="text-sm text-indigo-600">Total Events</p>
        </div>
        <div class="p-4 bg-purple-50 rounded-lg">
          <p class="text-3xl font-bold text-purple-900">{@metadata.decision_points}</p>
          <p class="text-sm text-purple-600">Decision Points</p>
        </div>
        <div class="p-4 bg-green-50 rounded-lg">
          <p class="text-3xl font-bold text-green-900">
            {Float.round(@metadata.avg_confidence * 100, 1)}%
          </p>
          <p class="text-sm text-green-600">Avg Confidence</p>
        </div>
        <div class="p-4 bg-orange-50 rounded-lg">
          <p class="text-3xl font-bold text-orange-900">{@metadata.alternatives_considered}</p>
          <p class="text-sm text-orange-600">Alternatives</p>
        </div>
      </div>
    </div>
    """
  end

  # Component: Event Filter
  attr :filter, :atom, required: true
  attr :events, :list, required: true

  defp event_filter(assigns) do
    event_types =
      assigns.events
      |> Enum.map(& &1.type)
      |> Enum.uniq()
      |> Enum.sort()

    assigns = assign(assigns, :event_types, event_types)

    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
      <h3 class="text-xl font-bold text-gray-900 mb-4">Filter by Event Type</h3>
      <div class="flex flex-wrap gap-2">
        <button
          phx-click="filter_events"
          phx-value-type="all"
          class={"px-4 py-2 rounded-md font-medium transition-colors #{if @filter == :all, do: "bg-indigo-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"}"}
        >
          All ({length(@events)})
        </button>
        <%= for type <- @event_types do %>
          <button
            phx-click="filter_events"
            phx-value-type={type}
            class={"px-4 py-2 rounded-md font-medium transition-colors #{if @filter == type, do: event_type_color_selected(type), else: "bg-gray-200 text-gray-700 hover:bg-gray-300"}"}
          >
            {format_event_type(type)} ({count_events(@events, type)})
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  # Component: Timeline Visualization
  attr :trace, :map, required: true
  attr :selected_event, :map
  attr :event_filter, :atom, required: true

  defp timeline_visualization(assigns) do
    assigns =
      assign(
        assigns,
        :filtered_events,
        filtered_events(assigns.trace.events, assigns.event_filter)
      )

    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
      <h3 class="text-xl font-bold text-gray-900 mb-4">Reasoning Timeline</h3>
      
    <!-- Timeline Container (Horizontal Scroll) -->
      <div class="overflow-x-auto pb-4">
        <div class="inline-flex items-start space-x-4 min-w-full px-4">
          <%= for {event, index} <- Enum.with_index(@filtered_events) do %>
            <div class="flex flex-col items-center" style="min-width: 200px;">
              <!-- Timeline Node -->
              <button
                phx-click="select_event"
                phx-value-event_id={event.id}
                class={"relative w-16 h-16 rounded-full flex items-center justify-center cursor-pointer transition-all #{if @selected_event && @selected_event.id == event.id, do: "ring-4 ring-indigo-300 scale-110", else: "hover:scale-105"} #{event_type_color(event.type)}"}
              >
                <span class="text-2xl">{event_type_icon(event.type)}</span>
              </button>
              
    <!-- Connector Line -->
              <%= if index < length(@filtered_events) - 1 do %>
                <div class="absolute w-32 h-1 bg-gray-300 left-20 top-8" style="margin-left: 32px;">
                </div>
              <% end %>
              
    <!-- Event Info -->
              <div class="mt-4 text-center">
                <p class="text-xs font-bold text-gray-700 mb-1">
                  Step {event.id}
                </p>
                <p class="text-xs text-gray-600 line-clamp-2 max-w-[200px]">
                  {event.title}
                </p>
                <div class="mt-2">
                  <div class="w-full bg-gray-200 rounded-full h-2">
                    <div
                      class="bg-green-500 h-2 rounded-full"
                      style={"width: #{event.confidence * 100}%"}
                    >
                    </div>
                  </div>
                  <p class="text-xs text-gray-500 mt-1">
                    {Float.round(event.confidence * 100, 1)}% confidence
                  </p>
                </div>
                
    <!-- Alternatives Indicator -->
                <%= if is_list(event.alternatives) and length(event.alternatives) > 0 do %>
                  <div class="mt-2 flex items-center justify-center text-xs text-orange-600">
                    <span class="mr-1">🔀</span>
                    {length(event.alternatives)} alt
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <%= if length(@filtered_events) == 0 do %>
        <p class="text-center text-gray-500 py-8">
          No events match the selected filter
        </p>
      <% end %>
    </div>
    """
  end

  # Component: Event Detail Panel
  attr :event, :map, required: true

  defp event_detail_panel(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-6 mb-6 border-2 border-indigo-500">
      <div class="flex items-start justify-between mb-4">
        <div>
          <h3 class="text-2xl font-bold text-gray-900">{@event.title}</h3>
          <div class="flex items-center space-x-4 mt-2">
            <span class={"px-3 py-1 rounded-full text-sm font-medium #{event_type_color_badge(@event.type)}"}>
              {event_type_icon(@event.type)} {format_event_type(@event.type)}
            </span>
            <span class="text-sm text-gray-600">
              Step {@event.id}
            </span>
          </div>
        </div>
        <div class="text-right">
          <p class="text-3xl font-bold text-green-600">
            {Float.round(@event.confidence * 100, 1)}%
          </p>
          <p class="text-sm text-gray-600">Confidence</p>
        </div>
      </div>
      
    <!-- Description -->
      <div class="mb-4">
        <h4 class="font-semibold text-gray-700 mb-2">Description</h4>
        <p class="text-gray-600">{@event.description}</p>
      </div>
      
    <!-- Reasoning -->
      <div class="mb-4">
        <h4 class="font-semibold text-gray-700 mb-2">Reasoning</h4>
        <p class="text-gray-600">{@event.reasoning}</p>
      </div>
      
    <!-- Alternatives (if any) -->
      <%= if is_list(@event.alternatives) and length(@event.alternatives) > 0 do %>
        <div class="mb-4">
          <h4 class="font-semibold text-gray-700 mb-2">
            Alternatives Considered ({length(@event.alternatives)})
          </h4>
          <%= if is_map(List.first(@event.alternatives)) do %>
            <!-- Structured alternatives (decision points) -->
            <div class="space-y-3">
              <%= for alt <- @event.alternatives do %>
                <div class="p-3 bg-gray-50 rounded-md border border-gray-200">
                  <div class="flex items-center justify-between mb-2">
                    <h5 class="font-medium text-gray-900">{alt.option}</h5>
                    <span class="text-sm font-semibold text-indigo-600">
                      {Float.round(alt.confidence * 100, 1)}%
                    </span>
                  </div>
                  <div class="grid grid-cols-2 gap-2 text-sm">
                    <div>
                      <p class="text-gray-600"><strong>Pros:</strong> {alt.pros}</p>
                    </div>
                    <div>
                      <p class="text-gray-600"><strong>Cons:</strong> {alt.cons}</p>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          <% else %>
            <!-- Simple string alternatives -->
            <ul class="list-disc list-inside space-y-1">
              <%= for alt <- @event.alternatives do %>
                <li class="text-gray-600">{alt}</li>
              <% end %>
            </ul>
          <% end %>
        </div>
      <% end %>
      
    <!-- Uncertainty Factors -->
      <%= if length(@event.uncertainty_factors) > 0 do %>
        <div class="mb-4">
          <h4 class="font-semibold text-gray-700 mb-2">Uncertainty Factors</h4>
          <ul class="list-disc list-inside space-y-1">
            <%= for factor <- @event.uncertainty_factors do %>
              <li class="text-orange-600">{factor}</li>
            <% end %>
          </ul>
        </div>
      <% end %>
      
    <!-- Timestamp -->
      <div class="pt-4 border-t border-gray-200">
        <p class="text-xs text-gray-500">
          Timestamp: {Calendar.strftime(@event.timestamp, "%Y-%m-%d %H:%M:%S.%f")}
        </p>
      </div>
    </div>
    """
  end

  # Component: Confidence Graph
  attr :events, :list, required: true

  defp confidence_graph(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-6">
      <h3 class="text-xl font-bold text-gray-900 mb-4">Confidence Over Time</h3>

      <div class="relative h-64">
        <!-- Y-axis labels -->
        <div class="absolute left-0 top-0 bottom-0 w-12 flex flex-col justify-between text-xs text-gray-600">
          <span>100%</span>
          <span>75%</span>
          <span>50%</span>
          <span>25%</span>
          <span>0%</span>
        </div>
        
    <!-- Graph area -->
        <div class="absolute left-14 right-0 top-0 bottom-8">
          <!-- Grid lines -->
          <div class="absolute inset-0 flex flex-col justify-between">
            <%= for _ <- 0..4 do %>
              <div class="border-t border-gray-200"></div>
            <% end %>
          </div>
          
    <!-- Confidence line -->
          <svg class="absolute inset-0 w-full h-full">
            <polyline
              points={confidence_polyline_points(@events)}
              fill="none"
              stroke="#4F46E5"
              stroke-width="2"
            />
            <!-- Data points -->
            <%= for {event, index} <- Enum.with_index(@events) do %>
              <% x = index / max(length(@events) - 1, 1) * 100
              y = (1 - event.confidence) * 100 %>
              <circle cx={"#{x}%"} cy={"#{y}%"} r="4" fill="#4F46E5" />
            <% end %>
          </svg>
        </div>
        
    <!-- X-axis -->
        <div class="absolute left-14 right-0 bottom-0 h-8 flex justify-between items-end text-xs text-gray-600">
          <%= for i <- [1, div(length(@events), 2), length(@events)] do %>
            <span>Step {i}</span>
          <% end %>
        </div>
      </div>
      
    <!-- Legend -->
      <div class="mt-6 flex items-center justify-center space-x-6 text-sm">
        <div class="flex items-center">
          <div class="w-4 h-4 bg-green-500 rounded-full mr-2"></div>
          <span class="text-gray-600">High Confidence (90%+)</span>
        </div>
        <div class="flex items-center">
          <div class="w-4 h-4 bg-yellow-500 rounded-full mr-2"></div>
          <span class="text-gray-600">Medium Confidence (70-90%)</span>
        </div>
        <div class="flex items-center">
          <div class="w-4 h-4 bg-red-500 rounded-full mr-2"></div>
          <span class="text-gray-600">Low Confidence (&lt;70%)</span>
        </div>
      </div>
    </div>
    """
  end

  # Component: Export Modal
  attr :trace, :map, required: true

  defp export_modal(assigns) do
    exported = TraceDemo.export_trace(assigns.trace)
    json = Jason.encode!(exported, pretty: true)
    assigns = assign(assigns, :json, json)

    ~H"""
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[80vh] overflow-hidden">
        <div class="p-6 border-b border-gray-200 flex items-center justify-between">
          <h3 class="text-2xl font-bold text-gray-900">Export Trace JSON</h3>
          <button phx-click="close_export" class="text-gray-500 hover:text-gray-700">
            <svg
              class="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              >
              </path>
            </svg>
          </button>
        </div>
        <div class="p-6 overflow-y-auto max-h-[60vh]">
          <pre class="bg-gray-50 p-4 rounded-md overflow-x-auto text-xs font-mono">{@json}</pre>
        </div>
        <div class="p-6 border-t border-gray-200 flex justify-end">
          <button
            phx-click="close_export"
            class="px-6 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
          >
            Close
          </button>
        </div>
      </div>
    </div>
    """
  end

  # Helper Functions

  defp filtered_events(events, :all), do: events

  defp filtered_events(events, filter) do
    Enum.filter(events, &(&1.type == filter))
  end

  defp count_events(events, type) do
    Enum.count(events, &(&1.type == type))
  end

  defp format_event_type(type) do
    type
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp event_type_icon(:task_decomposition), do: "🧩"
  defp event_type_icon(:hypothesis_formation), do: "💡"
  defp event_type_icon(:pattern_recognition), do: "🎯"
  defp event_type_icon(:decision_point), do: "⚖️"
  defp event_type_icon(:alternatives_considered), do: "🔀"
  defp event_type_icon(:constraint_check), do: "✓"
  defp event_type_icon(:uncertainty_estimation), do: "📊"
  defp event_type_icon(:synthesis), do: "🎓"
  defp event_type_icon(:calculation), do: "🔢"
  defp event_type_icon(:verification), do: "✅"
  defp event_type_icon(:additional_workup), do: "🔬"
  defp event_type_icon(:monitoring), do: "📈"
  defp event_type_icon(:solution_design), do: "🛠️"
  defp event_type_icon(:code_example), do: "💻"
  defp event_type_icon(:strategic_consideration), do: "🎲"
  defp event_type_icon(:implementation), do: "🚀"
  defp event_type_icon(_), do: "📝"

  defp event_type_color(:task_decomposition), do: "bg-blue-500 text-white"
  defp event_type_color(:hypothesis_formation), do: "bg-purple-500 text-white"
  defp event_type_color(:pattern_recognition), do: "bg-green-500 text-white"
  defp event_type_color(:decision_point), do: "bg-orange-500 text-white"
  defp event_type_color(:alternatives_considered), do: "bg-yellow-500 text-white"
  defp event_type_color(:constraint_check), do: "bg-teal-500 text-white"
  defp event_type_color(:uncertainty_estimation), do: "bg-red-500 text-white"
  defp event_type_color(:synthesis), do: "bg-indigo-500 text-white"
  defp event_type_color(:calculation), do: "bg-cyan-500 text-white"
  defp event_type_color(:verification), do: "bg-green-600 text-white"
  defp event_type_color(:additional_workup), do: "bg-pink-500 text-white"
  defp event_type_color(:monitoring), do: "bg-amber-500 text-white"
  defp event_type_color(:solution_design), do: "bg-violet-500 text-white"
  defp event_type_color(:code_example), do: "bg-slate-500 text-white"
  defp event_type_color(:strategic_consideration), do: "bg-rose-500 text-white"
  defp event_type_color(:implementation), do: "bg-emerald-500 text-white"
  defp event_type_color(_), do: "bg-gray-500 text-white"

  defp event_type_color_selected(:task_decomposition), do: "bg-blue-600 text-white"
  defp event_type_color_selected(:hypothesis_formation), do: "bg-purple-600 text-white"
  defp event_type_color_selected(:pattern_recognition), do: "bg-green-600 text-white"
  defp event_type_color_selected(:decision_point), do: "bg-orange-600 text-white"
  defp event_type_color_selected(:alternatives_considered), do: "bg-yellow-600 text-white"
  defp event_type_color_selected(:constraint_check), do: "bg-teal-600 text-white"
  defp event_type_color_selected(:uncertainty_estimation), do: "bg-red-600 text-white"
  defp event_type_color_selected(:synthesis), do: "bg-indigo-600 text-white"
  defp event_type_color_selected(:calculation), do: "bg-cyan-600 text-white"
  defp event_type_color_selected(:verification), do: "bg-green-700 text-white"
  defp event_type_color_selected(:additional_workup), do: "bg-pink-600 text-white"
  defp event_type_color_selected(:monitoring), do: "bg-amber-600 text-white"
  defp event_type_color_selected(:solution_design), do: "bg-violet-600 text-white"
  defp event_type_color_selected(:code_example), do: "bg-slate-600 text-white"
  defp event_type_color_selected(:strategic_consideration), do: "bg-rose-600 text-white"
  defp event_type_color_selected(:implementation), do: "bg-emerald-600 text-white"
  defp event_type_color_selected(_), do: "bg-gray-600 text-white"

  defp event_type_color_badge(:task_decomposition), do: "bg-blue-100 text-blue-800"
  defp event_type_color_badge(:hypothesis_formation), do: "bg-purple-100 text-purple-800"
  defp event_type_color_badge(:pattern_recognition), do: "bg-green-100 text-green-800"
  defp event_type_color_badge(:decision_point), do: "bg-orange-100 text-orange-800"
  defp event_type_color_badge(:alternatives_considered), do: "bg-yellow-100 text-yellow-800"
  defp event_type_color_badge(:constraint_check), do: "bg-teal-100 text-teal-800"
  defp event_type_color_badge(:uncertainty_estimation), do: "bg-red-100 text-red-800"
  defp event_type_color_badge(:synthesis), do: "bg-indigo-100 text-indigo-800"
  defp event_type_color_badge(:calculation), do: "bg-cyan-100 text-cyan-800"
  defp event_type_color_badge(:verification), do: "bg-green-100 text-green-800"
  defp event_type_color_badge(:additional_workup), do: "bg-pink-100 text-pink-800"
  defp event_type_color_badge(:monitoring), do: "bg-amber-100 text-amber-800"
  defp event_type_color_badge(:solution_design), do: "bg-violet-100 text-violet-800"
  defp event_type_color_badge(:code_example), do: "bg-slate-100 text-slate-800"
  defp event_type_color_badge(:strategic_consideration), do: "bg-rose-100 text-rose-800"
  defp event_type_color_badge(:implementation), do: "bg-emerald-100 text-emerald-800"
  defp event_type_color_badge(_), do: "bg-gray-100 text-gray-800"

  defp confidence_polyline_points(events) when length(events) == 0, do: ""

  defp confidence_polyline_points(events) do
    events
    |> Enum.with_index()
    |> Enum.map(fn {event, index} ->
      x = index / max(length(events) - 1, 1) * 100
      y = (1 - event.confidence) * 100
      "#{x}%,#{y}%"
    end)
    |> Enum.join(" ")
  end
end
