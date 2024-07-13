defmodule SecretQuest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SecretQuestWeb.Telemetry,
      SecretQuest.Repo,
      {DNSCluster, query: Application.get_env(:secret_quest, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SecretQuest.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SecretQuest.Finch},
      # Start a worker by calling: SecretQuest.Worker.start_link(arg)
      # {SecretQuest.Worker, arg},
      SecretQuestWeb.Presence,
      SecretQuest.Scheduler,
      # Start to serve requests, typically the last entry
      SecretQuestWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SecretQuest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SecretQuestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
