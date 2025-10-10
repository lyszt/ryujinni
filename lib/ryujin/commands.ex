# RYUJIN commands



defmodule Ryujin.CommandRegister do
  use GenServer
  require Logger
  alias Nostrum.Api.ApplicationCommand
  alias Nostrum.Api.Self

  @commands [
    %{
      name: "join",
      description: "Have the bot join your voice channel"
    },
    %{
      name: "ping",
      description: "Replies with pong!"
    },
    %{
      name: "leave",
      description: "Have the bot leave the current voice channel"
    }
  ]


  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Process.send_after(self(), :register_commands, 3_000)
    {:ok, %{}}
  end


  @impl true
  def handle_info(:register_commands, state) do
      Nostrum.Api.ApplicationCommand.create_global_command(@commands)
      ApplicationCommand.bulk_overwrite_guild_commands(Lygon.id(), @commands)
      Logger.info("Registering global commands...")
      :timer.sleep(1000)
      {:noreply, state}
    end
end
