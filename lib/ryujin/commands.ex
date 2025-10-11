# RYUJIN commands



defmodule Ryujin.CommandRegister do
  use GenServer
  require Logger
  alias Nostrum.Api.ApplicationCommand
  alias Nostrum.Api.Self

  @commands [
    %{
      name: "join",
      description: "Faz o bot entrar no seu canal de voz."
    },
    %{
      name: "play",
      description: "Toque uma bela música para seus amigos."
    },
    %{
      name: "leave",
      description: "Faz o bot sair do canal de voz atual."
    },
    %{
      name: "camara_eventos",
      description: "Veja uma lista de eventos previstos nos diversos orgãos da câmara de deputados."
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
