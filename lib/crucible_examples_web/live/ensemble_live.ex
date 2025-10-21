defmodule CrucibleExamplesWeb.EnsembleLive do
  use CrucibleExamplesWeb, :live_view

  alias CrucibleExamples.Scenarios.EnsembleDemo
  alias CrucibleExamples.Mock.Datasets

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Ensemble Reliability Dashboard")
      |> assign(questions: Datasets.medical_questions())
      |> assign(selected_question_id: 1)
      |> assign(voting_strategy: :majority)
      |> assign(result: nil)
      |> assign(loading: false)
      |> assign(show_comparison: false)
      |> assign(comparison_result: nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_question", %{"question_id" => question_id}, socket) do
    {:noreply, assign(socket, selected_question_id: String.to_integer(question_id), result: nil)}
  end

  @impl true
  def handle_event("select_strategy", %{"strategy" => strategy}, socket) do
    {:noreply, assign(socket, voting_strategy: String.to_existing_atom(strategy), result: nil)}
  end

  @impl true
  def handle_event("run_ensemble", _params, socket) do
    # Show loading state
    socket = assign(socket, loading: true)
    send(self(), :execute_ensemble)
    {:noreply, socket}
  end

  @impl true
  def handle_event("run_comparison", _params, socket) do
    socket = assign(socket, loading: true, show_comparison: true)
    send(self(), :execute_comparison)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, result: nil, show_comparison: false, comparison_result: nil)}
  end

  @impl true
  def handle_info(:execute_ensemble, socket) do
    # Run ensemble prediction
    result =
      EnsembleDemo.run_ensemble(
        socket.assigns.selected_question_id,
        socket.assigns.voting_strategy,
        simulate_delay: true
      )

    {:noreply, assign(socket, result: result, loading: false)}
  end

  @impl true
  def handle_info(:execute_comparison, socket) do
    # Run comparison
    comparison_result = EnsembleDemo.compare_single_vs_ensemble(10)

    {:noreply, assign(socket, comparison_result: comparison_result, loading: false)}
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
            🎯 Ensemble Reliability Dashboard
          </h1>
          <p class="text-lg text-gray-600 mb-3">
            Medical diagnosis assistant: Watch 5 models vote on high-stakes decisions
          </p>
          <div class="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
            <p class="text-sm text-gray-700">
              <strong>What you'll see:</strong>
              Ensemble voting combines multiple models to achieve higher reliability (96-99%)
              compared to single models (89-92%). This is crucial for high-stakes decisions like medical diagnosis where
              errors can be costly. Watch how 5 different models analyze the same question and vote together.
            </p>
          </div>
        </div>
        
    <!-- Configuration Panel -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 class="text-2xl font-bold text-gray-900 mb-4">Configuration</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Question Selector -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Select Medical Question
              </label>
              <select
                phx-change="select_question"
                name="question_id"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
              >
                <%= for q <- @questions do %>
                  <option value={q.id} selected={q.id == @selected_question_id}>
                    Question {q.id} - {q.difficulty}
                  </option>
                <% end %>
              </select>

              <%= if @selected_question_id do %>
                <div class="mt-4 p-4 bg-gray-50 rounded-md">
                  <p class="text-sm text-gray-700 font-medium mb-2">Question:</p>
                  <p class="text-sm text-gray-600">
                    {Enum.find(@questions, &(&1.id == @selected_question_id)).question}
                  </p>
                </div>
              <% end %>
            </div>
            
    <!-- Voting Strategy -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Voting Strategy
              </label>
              <select
                phx-change="select_strategy"
                name="strategy"
                class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
              >
                <option value="majority" selected={@voting_strategy == :majority}>
                  Majority Vote (most common answer wins)
                </option>
                <option value="weighted" selected={@voting_strategy == :weighted}>
                  Weighted Vote (by confidence)
                </option>
                <option value="unanimous" selected={@voting_strategy == :unanimous}>
                  Unanimous (all must agree)
                </option>
                <option value="best_confidence" selected={@voting_strategy == :best_confidence}>
                  Best Confidence (highest confidence wins)
                </option>
              </select>

              <div class="mt-4 space-y-2">
                <button
                  phx-click="run_ensemble"
                  disabled={@loading}
                  class="w-full px-6 py-3 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                >
                  {if @loading, do: "Running...", else: "Run Ensemble Prediction"}
                </button>

                <button
                  phx-click="run_comparison"
                  disabled={@loading}
                  class="w-full px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                >
                  {if @loading, do: "Analyzing...", else: "Compare Single vs Ensemble (10 questions)"}
                </button>

                <%= if @result || @comparison_result do %>
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
          <.ensemble_results result={@result} />
        <% end %>
        
    <!-- Comparison Results -->
        <%= if @show_comparison && @comparison_result do %>
          <.comparison_results result={@comparison_result} />
        <% end %>
      </div>
    </div>
    """
  end

  # Component: Ensemble Results
  attr :result, :map, required: true

  defp ensemble_results(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Verdict Banner -->
      <div class={"rounded-lg p-6 #{if @result.is_correct, do: "bg-green-100 border-2 border-green-500", else: "bg-red-100 border-2 border-red-500"}"}>
        <div class="flex items-center justify-between">
          <div>
            <h3 class="text-2xl font-bold text-gray-900 mb-2">
              {if @result.is_correct, do: "✅ Correct!", else: "❌ Incorrect"}
            </h3>
            <p class="text-lg text-gray-700">
              Ensemble Answer: <strong>{@result.vote_result.final_answer}</strong>
            </p>
            <p class="text-sm text-gray-600 mt-1">
              Correct Answer: {@result.question.correct_answer}
            </p>
          </div>
          <div class="text-right">
            <p class="text-3xl font-bold text-gray-900">
              {Float.round(@result.consensus.consensus * 100, 1)}%
            </p>
            <p class="text-sm text-gray-600">Consensus</p>
          </div>
        </div>
      </div>
      
    <!-- Model Responses -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Model Responses</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for {model_id, response_result} <- @result.model_responses do %>
            <%= case response_result do %>
              <% {:ok, response} -> %>
                <div class={"p-4 rounded-lg border-2 transition-all duration-300 hover:shadow-lg #{if response.answer == @result.vote_result.final_answer, do: "border-indigo-500 bg-indigo-50 shadow-md", else: "border-gray-200 bg-white hover:border-gray-300"}"}>
                  <div class="flex items-center justify-between mb-3">
                    <div class="flex items-center gap-2">
                      <div class="w-2 h-2 rounded-full bg-indigo-600 animate-pulse"></div>
                      <h4 class="font-bold text-gray-900">{response.model_name}</h4>
                    </div>
                    <span class={"px-2 py-1 text-xs font-semibold rounded #{if response.answer == @result.question.correct_answer, do: "bg-green-100 text-green-800", else: "bg-gray-100 text-gray-600"}"}>
                      {if response.answer == @result.question.correct_answer,
                        do: "✓ Correct",
                        else: "✗ Wrong"}
                    </span>
                  </div>
                  <div class="mb-3 p-2 bg-gray-50 rounded">
                    <p class="text-xs text-gray-500 mb-1">Answer:</p>
                    <p class="text-sm font-semibold text-gray-900">{response.answer}</p>
                  </div>
                  <div class="space-y-1">
                    <div class="flex items-center justify-between text-xs">
                      <span class="text-gray-600">Confidence:</span>
                      <div class="flex items-center gap-2">
                        <div class="w-24 bg-gray-200 rounded-full h-2">
                          <div
                            class="bg-indigo-600 h-2 rounded-full"
                            style={"width: #{response.confidence * 100}%"}
                          >
                          </div>
                        </div>
                        <span class="font-mono text-gray-900">
                          {Float.round(response.confidence * 100, 1)}%
                        </span>
                      </div>
                    </div>
                    <div class="flex items-center justify-between text-xs text-gray-600">
                      <span>Latency:</span>
                      <span class="font-mono">{response.latency_ms}ms</span>
                    </div>
                    <div class="flex items-center justify-between text-xs text-gray-600">
                      <span>Cost:</span>
                      <span class="font-mono">${response.cost_usd}</span>
                    </div>
                  </div>
                </div>
              <% {:error, error} -> %>
                <div class="p-4 rounded-lg border-2 border-red-200 bg-red-50">
                  <h4 class="font-bold text-red-900">{model_id}</h4>
                  <p class="text-sm text-red-700">Error: {inspect(error)}</p>
                </div>
            <% end %>
          <% end %>
        </div>
      </div>
      
    <!-- Voting Analysis -->
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Voting Analysis</h3>
        
    <!-- Strategy Explanation -->
        <div class="mb-4 p-3 bg-amber-50 border-l-4 border-amber-500 rounded">
          <p class="text-sm text-gray-700">
            <strong>Strategy: {String.capitalize(to_string(@result.voting_strategy))}</strong>
            - {strategy_explanation(@result.voting_strategy)}
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h4 class="font-semibold text-gray-700 mb-3">Vote Distribution</h4>
            <%= if Map.has_key?(@result.vote_result, :vote_distribution) do %>
              <div class="space-y-3">
                <%= for {answer, count} <- @result.vote_result.vote_distribution do %>
                  <div class="space-y-1">
                    <div class="flex items-center justify-between text-xs">
                      <span class="text-gray-600 font-medium truncate max-w-[150px]" title={answer}>
                        {answer}
                      </span>
                      <span class="text-gray-500">{count} vote(s)</span>
                    </div>
                    <div class="flex items-center gap-2">
                      <div class="flex-1 bg-gray-200 rounded-full h-8 overflow-hidden">
                        <div
                          class={"h-8 rounded-full flex items-center justify-center text-white text-xs font-bold transition-all duration-500 #{if answer == @result.vote_result.final_answer, do: "bg-gradient-to-r from-indigo-500 to-indigo-600", else: "bg-gray-400"}"}
                          style={"width: #{count / map_size(@result.vote_result.vote_distribution) * 100}%"}
                        >
                          <%= if count / map_size(@result.vote_result.vote_distribution) > 0.15 do %>
                            {Float.round(
                              count / map_size(@result.vote_result.vote_distribution) * 100,
                              0
                            )}%
                          <% end %>
                        </div>
                      </div>
                      <%= if answer == @result.vote_result.final_answer do %>
                        <span class="text-indigo-600 font-bold">🏆</span>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <div>
            <h4 class="font-semibold text-gray-700 mb-2">Cost Analysis</h4>
            <div class="space-y-2 text-sm">
              <div class="flex justify-between">
                <span class="text-gray-600">Single Model (GPT-4):</span>
                <span class="font-mono">${@result.cost_analysis.single_model_cost}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">Ensemble (5 models):</span>
                <span class="font-mono">${@result.cost_analysis.ensemble_cost}</span>
              </div>
              <div class="flex justify-between border-t pt-2">
                <span class="text-gray-600">Overhead:</span>
                <span class="font-mono text-orange-600">+{@result.cost_analysis.overhead_pct}%</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Component: Comparison Results
  attr :result, :map, required: true

  defp comparison_results(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-6 mt-6">
      <h3 class="text-2xl font-bold text-gray-900 mb-4">Single vs Ensemble Comparison</h3>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <!-- Single Model Stats -->
        <div class="p-4 bg-gray-50 rounded-lg">
          <h4 class="font-semibold text-gray-700 mb-3">Single Model (GPT-4)</h4>
          <div class="space-y-2">
            <div>
              <p class="text-3xl font-bold text-gray-900">
                {Float.round(@result.single_model.accuracy * 100, 1)}%
              </p>
              <p class="text-sm text-gray-600">Accuracy</p>
            </div>
            <div class="text-sm text-gray-600">
              Avg Cost: ${@result.single_model.avg_cost}
            </div>
          </div>
        </div>
        
    <!-- Ensemble Stats -->
        <div class="p-4 bg-indigo-50 rounded-lg">
          <h4 class="font-semibold text-indigo-700 mb-3">Ensemble (5 models)</h4>
          <div class="space-y-2">
            <div>
              <p class="text-3xl font-bold text-indigo-900">
                {Float.round(@result.ensemble.accuracy * 100, 1)}%
              </p>
              <p class="text-sm text-indigo-600">Accuracy</p>
            </div>
            <div class="text-sm text-indigo-600">
              Avg Cost: ${@result.ensemble.avg_cost}
            </div>
            <div class="text-sm text-indigo-600">
              Consensus: {Float.round(@result.ensemble.avg_consensus * 100, 1)}%
            </div>
          </div>
        </div>
        
    <!-- Improvement -->
        <div class="p-4 bg-green-50 rounded-lg">
          <h4 class="font-semibold text-green-700 mb-3">Improvement</h4>
          <div class="space-y-2">
            <div>
              <p class="text-3xl font-bold text-green-900">
                +{@result.improvement.accuracy_gain}%
              </p>
              <p class="text-sm text-green-600">Accuracy Gain</p>
            </div>
            <div class="text-sm text-orange-600">
              {@result.improvement.cost_multiplier}x cost
            </div>
          </div>
        </div>
      </div>

      <p class="text-sm text-gray-600 text-center">
        Tested on {@result.num_questions} medical diagnosis questions
      </p>
    </div>
    """
  end

  # Helper function for strategy explanations
  defp strategy_explanation(:majority),
    do: "The most common answer across all models wins. Simple and effective."

  defp strategy_explanation(:weighted),
    do:
      "Each vote is weighted by the model's confidence score. Higher confidence votes count more."

  defp strategy_explanation(:unanimous),
    do: "All models must agree. If not unanimous, falls back to majority vote."

  defp strategy_explanation(:best_confidence),
    do: "The answer from the single most confident model wins. Fastest but least reliable."
end
