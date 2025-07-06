defmodule Tuvi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TuviWeb.Telemetry,
      Tuvi.Repo,
      {DNSCluster, query: Application.get_env(:tuvi, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tuvi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Tuvi.Finch},
      # Start a worker by calling: Tuvi.Worker.start_link(arg)
      # {Tuvi.Worker, arg},
      # Start to serve requests, typically the last entry
      TuviWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tuvi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TuviWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
