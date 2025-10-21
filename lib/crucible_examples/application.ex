defmodule CrucibleExamples.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CrucibleExamplesWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:crucible_examples, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CrucibleExamples.PubSub},
      # Start a worker by calling: CrucibleExamples.Worker.start_link(arg)
      # {CrucibleExamples.Worker, arg},
      # Start to serve requests, typically the last entry
      CrucibleExamplesWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CrucibleExamples.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CrucibleExamplesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
