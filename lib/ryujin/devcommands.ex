defmodule Ryujin.DevCommands do
  def clear_bot_commands do
    commands = Ryujin.CommandRegister.commands()

    Nostrum.Api.ApplicationCommand.bulk_overwrite_global_commands(commands)
    {:ok, guilds} = Nostrum.Api.Self.guilds()

    Enum.each(guilds, fn %Nostrum.Struct.Guild{id: guild_id} ->
      Nostrum.Api.ApplicationCommand.bulk_overwrite_guild_commands(guild_id, commands)
    end)

    :ok
  end
end
