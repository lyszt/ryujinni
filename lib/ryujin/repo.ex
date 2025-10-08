defmodule Ryujin.Repo do
  use Ecto.Repo,
    otp_app: :ryujin,
    adapter: Ecto.Adapters.Postgres
end
