defmodule Ryujin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RyujinWeb.Telemetry,
      Ryujin.Repo,
      {DNSCluster, query: Application.get_env(:ryujin, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ryujin.PubSub},
      RyujinWeb.Endpoint,
      Ryujin.Consumer
    ]

    opts = [strategy: :one_for_one, name: Ryujin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    RyujinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
