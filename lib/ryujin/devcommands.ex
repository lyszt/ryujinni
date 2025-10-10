
defmodule DevCommands do
  def clear_bot_commands do
      Nostrum.Api.ApplicationCommand.bulk_overwrite_global_commands([])
      IO.puts("All commands for Ryujin have been removed and cleaned. Restart the bot for changes.")
  end
end
