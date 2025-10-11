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
    case Nostrum.Cache.GuildCache.get(interaction.guild_id) do
      {:ok, guild = %Nostrum.Struct.Guild{}} ->
        voice_states = guild.voice_states
        Logger.info(voice_states)

        if voice_states != nil do
          # hd gets the top (head) out of a list
          user_voice_state = Enum.find(voice_states, fn state ->
            state.user_id == interaction.user.id
          end)
          Logger.info(user_voice_state)
          Nostrum.Api.Interaction.create_response(interaction, %{
            type: 4,
            data: %{
              content: "> Se juntando à chamada...",
              flags: 64
            }
          })
          Nostrum.Voice.join_channel(interaction.guild_id, user_voice_state[:channel_id])
        else
          Nostrum.Api.Interaction.create_response(interaction, %{
            type: 4,
            data: %{
              content: "> Desculpe, mas me parece que você não está em uma chamada de voz.",
              flags: 64 #
            }
          })
      end

    {:error, reason} ->
      Logger.error("Guild not found in cache: #{inspect(reason)}")
    end
  end

  @impl true
  def handle_event({:INTERACTION_CREATE, %Interaction{data: %{name: "play"}} = interaction, _ws_state}) do


  end

  @impl true
  def handle_event({:INTERACTION_CREATE, %Interaction{data: %{name: "leave"}} = interaction, _ws_state}) do
    Nostrum.Voice.leave_channel(interaction.guild_id)
    Nostrum.Api.Interaction.create_response(interaction, %{
      type: 4,
      data: %{
        content: "> Até mais, companheiro.",
        flags: 64
      }
    })
  end

  @impl true
  def handle_event({:INTERACTION_CREATE, %Interaction{data: %{name: "camara_eventos"}} = interaction, _ws_state}) do
    Nostrum.Api.Interaction.create_response(interaction, %{
              type: 4,
              data: %{
                content: "> Processando...",
                flags: 64 #
              }
            })

    %Interaction{application_id: app_id, token: token} = interaction
    case CamaraApi.Eventos.fetch_and_format_events() do
      {:ok, formatted_events} ->

        if Enum.empty?(formatted_events) do
          Message.create(interaction.channel_id, %{
            content: "Nenhum evento encontrado para o período especificado."
          })

        else
          embeds =
            Enum.map(formatted_events, fn event ->
              safe_description = String.slice(event.description, 0, 3800)

              %Nostrum.Struct.Embed{
                title: event.title,
                url: event.uri,
                color: "RANDOM",
                description:
                  "**Início:** #{event.start_time} UTC\n" <>
                  "**Local:** #{event.location}\n" <>
                  "**Órgãos:** #{event.organs}\n" <>
                  "**Situação:** #{event.situation}\n\n" <>
                  "--- \n" <>
                  "#{safe_description}" <>
                  (if String.length(event.description) > 3800, do: "...", else: ""),
                footer: %Nostrum.Struct.Embed.Footer{
                  text: "Dados da API de Dados Abertos da Câmara dos Deputados"
                }
              }
            end)

          for embed <- embeds do
            Message.create(interaction.channel_id, %{
            embed: embed
            })
          end
        end

      {:error, reason} ->
        Logger.error("Failed to fetch Camara events: #{inspect(reason)}")
        Message.create(interaction.channel_id, %{
          content: "Desculpe, não consegui carregar os eventos da Câmara no momento.",
        })
    end

    # private
  end
end
