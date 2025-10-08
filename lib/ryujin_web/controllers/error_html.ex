defmodule RyujinWeb.ErrorHTML do
  @moduledoc """
  HTML error renderer invoked by the endpoint when a controller fails.
  """
  use RyujinWeb, :html

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
