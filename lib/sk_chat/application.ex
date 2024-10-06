defmodule SkChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SkChatWeb.Telemetry,
      SkChat.Repo,
      {DNSCluster, query: Application.get_env(:sk_chat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SkChat.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SkChat.Finch},
      # Start a worker by calling: SkChat.Worker.start_link(arg)
      # {SkChat.Worker, arg},
      # Start to serve requests, typically the last entry
      SkChatWeb.Endpoint,
      SkChatWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SkChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SkChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
