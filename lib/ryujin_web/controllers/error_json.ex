defmodule RyujinWeb.ErrorJSON do
  @moduledoc """
  JSON error renderer invoked by the endpoint when an API request fails.
  """

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
