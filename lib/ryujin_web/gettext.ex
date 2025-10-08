defmodule RyujinWeb.Gettext do
  @moduledoc """
  Gettext backend for Ryujin; use with `use Gettext, backend: RyujinWeb.Gettext`.
  """
  use Gettext.Backend, otp_app: :ryujin
end
