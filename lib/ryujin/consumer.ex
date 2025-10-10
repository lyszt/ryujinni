defmodule Ryujin.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Cache.GuildCache
  alias Nostrum.Api.Voice
  alias Nostrum.Api.Message
  alias Nostrum.Struct.{Interaction, VoiceState}
  alias Nostrum.Api.Self


  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    lowered_msg = String.downcase(msg.content)
    if String.contains?(lowered_msg, "ryu") or String.contains?(lowered_msg, "ryujinni") do
      {:ok, _message} = Message.create(msg.channel_id, "Hello!")
    end
  end

  @impl true
  def handle_event({:INTERACTION_CREATE, %Interaction{data: %{name: "join"}} = interaction, _ws_state}) do
      case Nostrum.Api.Guild.get(interaction.guild_id) do
      {:ok, guild} ->
      Logger.info(guild)
      voice_state_map = guild.voice_states

      case voice_state_map do
        nil ->
        Nostrum.Api.Interaction.create_response(interaction, %{
              type: 4,
              data: %{
                content: "> Desculpe, mas me parece que você não está em uma chamada de voz.",
                flags: 64 # This is the EPHEMERAL flag
              }
            })

        voice_state->
          channel_id = Map.get(voice_state, interaction.user.id)
          Nostrum.Api.Interaction.create_response(interaction, %{
              type: 4, # This means CHANNEL_MESSAGE_WITH_SOURCE
              data: %{
                content: "> Se juntando à chamada...",
                flags: 64
              }
            })
            Nostrum.Voice.join_channel(interaction.guild_id, channel_id, true)
      end

    {:error, :not_found} ->
      Logger.error("Guild not found in cache")
    end
  end
end
