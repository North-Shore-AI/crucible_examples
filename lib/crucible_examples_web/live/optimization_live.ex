defmodule CrucibleExamplesWeb.OptimizationLive do
  use CrucibleExamplesWeb, :live_view

  alias CrucibleExamples.Scenarios.OptimizationDemo

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Optimization Playground")
      |> assign(strategy: :grid_search)
      |> assign(n_trials: 25)
      |> assign(result: nil)
      |> assign(loading: false)
      |> assign(progress: 0)
      |> assign(current_trial: 0)
      |> assign(validation_questions: OptimizationDemo.validation_questions())

    {:ok, socket}
  end

  @impl true
  def handle_event("select_strategy", %{"strategy" => strategy}, socket) do
    {:noreply, assign(socket, strategy: String.to_existing_atom(strategy), result: nil)}
  end

  @impl true
  def handle_event("select_trials", %{"trials" => trials}, socket) do
    {:noreply, assign(socket, n_trials: String.to_integer(trials), result: nil)}
  end

  @impl true
  def handle_event("run_optimization", _params, socket) do
    socket = assign(socket, loading: true, progress: 0, current_trial: 0)
    send(self(), :execute_optimization)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, result: nil, progress: 0, current_trial: 0)}
  end

  @impl true
  def handle_info(:execute_optimization, socket) do
    # Run optimization with progress updates
    result =
      OptimizationDemo.optimize_parameters(socket.assigns.strategy, socket.assigns.n_trials)

    {:noreply,
     assign(socket,
       result: result,
       loading: false,
       progress: 100,
       current_trial: socket.assigns.n_trials
     )}
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
            Optimization Playground
          </h1>
          <p class="text-lg text-gray-600">
            Systematic parameter search: Find optimal prompt configurations automatically
          </p>
        </div>
        
    <!-- Configuration Panel -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 class="text-2xl font-bold text-gray-900 mb-4">Configuration</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Strategy Selector -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Optimization Strategy
              </label>
              <select
                phx-change="select_strategy"
                name="strategy"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
                disabled={@loading}
              >
                <option value="grid_search" selected={@strategy == :grid_search}>
                  Grid Search - Exhaustive parameter space exploration
                </option>
                <option value="random_search" selected={@strategy == :random_search}>
                  Random Search - Efficient random sampling
                </option>
                <option value="bayesian" selected={@strategy == :bayesian}>
                  Bayesian Optimization - Intelligent exploration/exploitation
                </option>
              </select>

              <div class="mt-4 p-4 bg-gray-50 rounded-md">
                <p class="text-sm text-gray-700 font-medium mb-1">Strategy Details:</p>
                <p class="text-xs text-gray-600">
                  <%= case @strategy do %>
                    <% :grid_search -> %>
                      Systematically samples the entire parameter space in a grid pattern. Thorough but can be slow.
                    <% :random_search -> %>
                      Randomly samples configurations. Faster and often finds good solutions quickly.
                    <% :bayesian -> %>
                      Uses exploration phase then exploits promising regions. Most efficient for expensive evaluations.
                  <% end %>
                </p>
              </div>
            </div>
            
    <!-- Number of Trials -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Number of Trials
              </label>
              <select
                phx-change="select_trials"
                name="trials"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
                disabled={@loading}
              >
                <option value="10" selected={@n_trials == 10}>10 trials (Quick test)</option>
                <option value="25" selected={@n_trials == 25}>25 trials (Balanced)</option>
                <option value="50" selected={@n_trials == 50}>50 trials (Thorough)</option>
              </select>

              <div class="mt-4 p-4 bg-purple-50 rounded-md">
                <p class="text-sm text-purple-900 font-medium mb-2">Parameter Space:</p>
                <ul class="text-xs text-purple-700 space-y-1">
                  <li>• Temperature: 0.0 - 2.0</li>
                  <li>• Max Tokens: 100 - 2000</li>
                  <li>• Few-shot Examples: 0 - 10</li>
                </ul>
              </div>

              <div class="mt-4 space-y-2">
                <button
                  phx-click="run_optimization"
                  disabled={@loading}
                  class="w-full px-6 py-3 bg-purple-600 text-white rounded-md hover:bg-purple-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors font-medium"
                >
                  <%= if @loading do %>
                    Running Optimization...
                  <% else %>
                    Run Optimization
                  <% end %>
                </button>

                <%= if @result do %>
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
          
    <!-- Progress Bar -->
          <%= if @loading do %>
            <div class="mt-6">
              <div class="flex justify-between items-center mb-2">
                <span class="text-sm font-medium text-gray-700">Optimization Progress</span>
                <span class="text-sm text-gray-600">Running trials...</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-4">
                <div
                  class="bg-purple-600 h-4 rounded-full transition-all duration-300 flex items-center justify-center"
                  style={"width: #{@progress}%"}
                >
                  <span class="text-xs text-white font-bold">{@progress}%</span>
                </div>
              </div>
            </div>
          <% end %>
        </div>
        
    <!-- Results Section -->
        <%= if @result do %>
          <.optimization_results result={@result} />
        <% end %>
      </div>
    </div>
    """
  end

  # Component: Optimization Results
  attr :result, :map, required: true

  defp optimization_results(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Best Configuration Banner -->
      <div class="bg-gradient-to-r from-purple-100 to-pink-100 border-2 border-purple-500 rounded-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Optimal Configuration Found</h3>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <div class="space-y-3">
              <div class="flex items-center justify-between p-3 bg-white rounded-lg">
                <span class="font-medium text-gray-700">Temperature:</span>
                <span class="text-lg font-bold text-purple-600">
                  {@result.best_config.temperature}
                </span>
              </div>
              <div class="flex items-center justify-between p-3 bg-white rounded-lg">
                <span class="font-medium text-gray-700">Max Tokens:</span>
                <span class="text-lg font-bold text-purple-600">
                  {@result.best_config.max_tokens}
                </span>
              </div>
              <div class="flex items-center justify-between p-3 bg-white rounded-lg">
                <span class="font-medium text-gray-700">Few-shot Examples:</span>
                <span class="text-lg font-bold text-purple-600">
                  {@result.best_config.num_examples}
                </span>
              </div>
            </div>
          </div>

          <div class="flex items-center justify-center">
            <div class="text-center">
              <p class="text-6xl font-bold text-purple-600">
                {Float.round(@result.best_score * 100, 1)}%
              </p>
              <p class="text-lg text-gray-700 mt-2">Validation Accuracy</p>
              <p class="text-sm text-gray-600 mt-1">
                Evaluated on {length(@result.trials)} configurations
              </p>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Convergence Chart -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Convergence History</h3>
        <p class="text-sm text-gray-600 mb-4">
          Best score found at each trial (shows how quickly optimization improves)
        </p>

        <.convergence_chart convergence={@result.convergence_history} />
      </div>
      
    <!-- Parameter Analysis -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Parameter Impact Analysis</h3>
        <p class="text-sm text-gray-600 mb-4">
          Average accuracy for different parameter ranges
        </p>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <!-- Temperature Heatmap -->
          <div>
            <h4 class="font-semibold text-gray-700 mb-3">Temperature Ranges</h4>
            <.parameter_heatmap data={@result.parameter_analysis.temperature} param_name="temp" />
          </div>
          
    <!-- Max Tokens Heatmap -->
          <div>
            <h4 class="font-semibold text-gray-700 mb-3">Max Tokens Ranges</h4>
            <.parameter_heatmap data={@result.parameter_analysis.max_tokens} param_name="tokens" />
          </div>
          
    <!-- Examples Heatmap -->
          <div>
            <h4 class="font-semibold text-gray-700 mb-3">Few-shot Examples</h4>
            <.parameter_heatmap data={@result.parameter_analysis.num_examples} param_name="examples" />
          </div>
        </div>
      </div>
      
    <!-- Configuration Explorer -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Configuration Explorer</h3>
        <p class="text-sm text-gray-600 mb-4">
          All {length(@result.trials)} configurations evaluated (sorted by score)
        </p>

        <.configuration_table trials={@result.trials} />
      </div>
      
    <!-- Validation Details -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Validation Dataset</h3>
        <p class="text-sm text-gray-600 mb-4">
          Optimization objective: Maximize accuracy on math word problems
        </p>

        <div class="space-y-2">
          <%= for question <- Enum.take(CrucibleExamples.Scenarios.OptimizationDemo.validation_questions(), 3) do %>
            <div class="p-3 bg-gray-50 rounded-md">
              <p class="text-sm text-gray-700">{question.question}</p>
              <p class="text-xs text-gray-500 mt-1">Answer: {question.correct_answer}</p>
            </div>
          <% end %>
          <p class="text-xs text-gray-500 italic">
            ... and {length(CrucibleExamples.Scenarios.OptimizationDemo.validation_questions()) - 3} more questions
          </p>
        </div>
      </div>
    </div>
    """
  end

  # Component: Convergence Chart (ASCII-style bar chart)
  attr :convergence, :list, required: true

  defp convergence_chart(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= for entry <- Enum.take_every(@convergence, max(1, div(length(@convergence), 20))) do %>
        <div class="flex items-center gap-3">
          <div class="w-16 text-xs text-gray-600 text-right">
            Trial {entry.trial_number}
          </div>
          <div class="flex-1 bg-gray-200 rounded-full h-6 relative">
            <div
              class="bg-gradient-to-r from-purple-500 to-pink-500 h-6 rounded-full flex items-center justify-end pr-2"
              style={"width: #{entry.best_score * 100}%"}
            >
              <span class="text-xs text-white font-bold">
                {Float.round(entry.best_score * 100, 1)}%
              </span>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Component: Parameter Heatmap
  attr :data, :map, required: true
  attr :param_name, :string, required: true

  defp parameter_heatmap(assigns) do
    # Find max value for scaling
    max_value =
      if map_size(assigns.data) > 0, do: assigns.data |> Map.values() |> Enum.max(), else: 1

    assigns = assign(assigns, :max_value, max_value)

    ~H"""
    <div class="space-y-2">
      <%= for {range, score} <- Enum.sort(@data) do %>
        <div class="flex items-center gap-2">
          <div class="w-24 text-xs text-gray-600">{range}</div>
          <div class="flex-1 bg-gray-200 rounded h-8 relative overflow-hidden">
            <div
              class={"h-8 rounded flex items-center justify-end pr-2 transition-all #{score_color(score, @max_value)}"}
              style={"width: #{(score / @max_value) * 100}%"}
            >
              <span class="text-xs text-white font-bold">
                {Float.round(score * 100, 1)}%
              </span>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Component: Configuration Table
  attr :trials, :list, required: true

  defp configuration_table(assigns) do
    # Sort trials by score descending
    sorted_trials = Enum.sort_by(assigns.trials, & &1.score, :desc)
    assigns = assign(assigns, :sorted_trials, sorted_trials)

    ~H"""
    <div class="overflow-x-auto max-h-96 overflow-y-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50 sticky top-0">
          <tr>
            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Rank
            </th>
            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Trial
            </th>
            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Temperature
            </th>
            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Max Tokens
            </th>
            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Examples
            </th>
            <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Score
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <%= for {trial, rank} <- Enum.with_index(@sorted_trials, 1) do %>
            <tr class={if rank == 1, do: "bg-purple-50", else: ""}>
              <td class="px-4 py-3 whitespace-nowrap text-sm">
                <%= if rank == 1 do %>
                  <span class="font-bold text-purple-600">#{rank}</span>
                <% else %>
                  <span class="text-gray-500">#{rank}</span>
                <% end %>
              </td>
              <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                {trial.trial_number}
              </td>
              <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-900 font-mono">
                {trial.config.temperature}
              </td>
              <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-900 font-mono">
                {trial.config.max_tokens}
              </td>
              <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-900 font-mono">
                {trial.config.num_examples}
              </td>
              <td class="px-4 py-3 whitespace-nowrap text-sm">
                <span class={if rank == 1, do: "font-bold text-purple-600", else: "text-gray-900"}>
                  {Float.round(trial.score * 100, 1)}%
                </span>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  # Helper function to determine color based on score
  defp score_color(score, max_value) do
    percentage = score / max_value

    cond do
      percentage >= 0.9 -> "bg-green-500"
      percentage >= 0.8 -> "bg-lime-500"
      percentage >= 0.7 -> "bg-yellow-500"
      percentage >= 0.6 -> "bg-orange-500"
      true -> "bg-red-500"
    end
  end
end
