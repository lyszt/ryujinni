defmodule Ryujin.Consumer do
  @behaviour Nostrum.Consumer
  require Logger
  alias Nostrum.Api.Message
  alias Nostrum.Cache.GuildCache
  alias Nostrum.Struct.Interaction
  alias Ryujin.VoiceSession

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    lowered_msg = String.downcase(msg.content)

    if String.contains?(lowered_msg, "ryu") or String.contains?(lowered_msg, "ryujinni") do
      {:ok, _message} = Message.create(msg.channel_id, "Hello!")
    end
  end

  # VOICE COMMANDS
  # ========================================
  @impl true
  def handle_event(
        {:INTERACTION_CREATE, %Interaction{data: %{name: "join"}} = interaction, _ws_state}
      ) do
    case check_if_incall(interaction) do
      {:ok, voice_channel} ->
        Nostrum.Api.Interaction.create_response(interaction, %{
          type: 4,
          data: %{
            content: "> Se juntando à chamada...",
            flags: 64
          }
        })

        case VoiceSession.join(interaction.guild_id, voice_channel) do
          :ok ->
            :ok

          {:error, reason} ->
            Logger.warning(
              "Failed to ensure voice session for guild #{interaction.guild_id}: #{inspect(reason)}"
            )
        end

      {:not_found, nil} ->
        Nostrum.Api.Interaction.create_response(interaction, %{
          type: 4,
          data: %{
            content: "> Desculpe, mas me parece que você não está em uma chamada de voz.",
            #
            flags: 64
          }
        })

      {:error, reason} ->
        Logger.info("Guild not found in cache: #{inspect(reason)}")
    end
  end

  @impl true
  def handle_event(
        {:INTERACTION_CREATE, %Interaction{data: %{name: "play"}} = interaction, _ws_state}
      ) do
    case check_if_incall(interaction) do
      {:ok, voice_channel} ->
        case get_option(interaction, "query") do
          {:ok, url} when is_binary(url) and byte_size(url) > 0 ->
            case VoiceSession.join(interaction.guild_id, voice_channel) do
              :ok ->
                Nostrum.Api.Interaction.create_response(interaction,  %{
                  type: 4,
                  data: %{
                    content:
                      "> Tocando #{url}.",
                    flags: 64
                  }
                })
                VoiceSession.play(interaction.guild_id, url, :ytdl)

              {:error, reason} ->
                Logger.warning(
                  "Failed to join voice before playing on guild #{interaction.guild_id}: #{inspect(reason)}"
                )

                Nostrum.Api.Interaction.create_response(interaction, %{
                  type: 4,
                  data: %{
                    content:
                      "> Não consegui entrar na chamada para tocar a música. Tente novamente.",
                    flags: 64
                  }
                })
            end

          {:error, :missing} ->
            Nostrum.Api.Interaction.create_response(interaction, %{
              type: 4,
              data: %{
                content: "> Por favor, forneça um URL ou termo de busca para reproduzir.",
                flags: 64
              }
            })

          {:error, reason} ->
            Logger.info("Unexpected option parsing result: #{inspect(reason)}")
        end

      {:not_found, nil} ->
        Nostrum.Api.Interaction.create_response(interaction, %{
          type: 4,
          data: %{
            content: "> Desculpe, mas me parece que você não está em uma chamada de voz.",
            flags: 64
          }
        })

      {:error, reason} ->
        Logger.info("Guild not found in cache: #{inspect(reason)}")

      _ ->
        Logger.info("Unexpected response from check_if_incall/1")
    end
  end

  @impl true
  def handle_event(
        {:INTERACTION_CREATE, %Interaction{data: %{name: "leave"}} = interaction, _ws_state}
      ) do
    VoiceSession.leave(interaction.guild_id)

    Nostrum.Api.Interaction.create_response(interaction, %{
      type: 4,
      data: %{
        content: "> Até mais, companheiro.",
        flags: 64
      }
    })
  end

  # ================================================================================

  # Politics

  @impl true
  def handle_event(
        {:INTERACTION_CREATE, %Interaction{data: %{name: "camara_eventos"}} = interaction,
         _ws_state}
      ) do
    Nostrum.Api.Interaction.create_response(interaction, %{
      type: 4,
      data: %{
        content: "> Processando...",
        #
        flags: 64
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
                    if(String.length(event.description) > 3800, do: "...", else: ""),
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
        Logger.info("Failed to fetch Camara events: #{inspect(reason)}")

        Message.create(interaction.channel_id, %{
          content: "Desculpe, não consegui carregar os eventos da Câmara no momento."
        })
    end
  end

  # ===================================
  # PRIVATE

  defp check_if_incall(interaction) do
    case GuildCache.get(interaction.guild_id) do
      {:ok, guild = %Nostrum.Struct.Guild{}} ->
        voice_states = guild.voice_states

        if voice_states != nil do
          user_voice_state =
            Enum.find(voice_states, fn state ->
              state.user_id == interaction.user.id
            end)

          if user_voice_state[:channel_id] != nil do
            {:ok, user_voice_state[:channel_id]}
          end
        else
          {:not_found, nil}
        end

      {:error, reason} ->
        Logger.info("Guild not found: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Helper to fetch an option value by name from an Interaction's data
  defp get_option(%Interaction{data: %{options: options}} = _interaction, name)
       when is_list(options) do
    case Enum.find(options, fn opt -> Map.get(opt, :name) == name end) do
      %{value: value} -> {:ok, value}
      _ -> {:error, :missing}
    end
  end

  # Fallback: when options isn't a list or option isn't found
  defp get_option(_interaction, _name), do: {:error, :missing}

  @impl true
  def handle_event(_), do: :ok
end
