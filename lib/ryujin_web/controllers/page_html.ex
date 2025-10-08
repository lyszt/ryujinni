defmodule RyujinWeb.PageHTML do
  @moduledoc """
  Templates rendered by `RyujinWeb.PageController`.
  """
  use RyujinWeb, :html

  embed_templates "page_html/*"
end
