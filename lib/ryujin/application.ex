defmodule Ryujin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Nostrum.Api.Self

  @impl true
  def start(_type, _args) do
    children = [
      RyujinWeb.Telemetry,
      Ryujin.Repo,
      {DNSCluster, query: Application.get_env(:ryujin, :dns_cluster_query) || :ignore},
      {Finch, name: Ryujin.Finch},
      {Phoenix.PubSub, name: Ryujin.PubSub},
      RyujinWeb.Endpoint,
      Ryujin.Consumer,
      Ryujin.CommandRegister

    ]

    opts = [strategy: :one_for_one, name: Ryujin.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    Task.start(
      fn ->
        {:ok, active_servers} = Self.guilds()
        :timer.sleep(1000)
        Self.update_status(:online, "as noticias do império lygoniano ao #{Enum.random(active_servers).name}.", 1, "https://youtu.be/47AVNwXG3CA")
      end

    )
    {:ok, pid}
  end

  @impl true
  def config_change(changed, _new, removed) do
    RyujinWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end
