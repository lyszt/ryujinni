defmodule Ryujin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    bot_options = %{
      name: MyBot,
      consumer: MyBot.Consumer,
      intents: [:direct_messages, :guild_messages, :message_content],
      wrapped_token: fn -> System.fetch_env!(Application.get_env(:ryujin, :bot_token)) end
    }
    children = [
      {Nostrum.Bot, bot_options}
    ]

    children = [
      # Starts a worker by calling: Ryujin.Worker.start_link(arg)
      # {Ryujin.Worker, arg}
    ]


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ryujin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
