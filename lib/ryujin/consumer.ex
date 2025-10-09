defmodule Ryujin.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api.Message

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    lowered_msg = String.downcase(msg.content)
    if String.contains?(lowered_msg, "ryu") or String.contains?(lowered_msg, "ryujinni") do
      {:ok, _message} = Message.create(msg.channel_id, "Hello!")
    end
  end
end
