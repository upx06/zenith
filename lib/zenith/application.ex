defmodule Zenith.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ZenithWeb.Telemetry,
      Zenith.Repo,
      {DNSCluster, query: Application.get_env(:zenith, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Zenith.PubSub},
      # Start a worker by calling: Zenith.Worker.start_link(arg)
      # {Zenith.Worker, arg},
      # Start to serve requests, typically the last entry
      ZenithWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :zenith]},
      {Absinthe.Subscription, ZenithWeb.Endpoint},
      AshGraphql.Subscription.Batcher
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zenith.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ZenithWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
