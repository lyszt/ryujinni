# Used by "mix format"
[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  subdirectories: ["priv/*/migrations"],
  inputs: [
    "{mix,.formatter}.exs",
    "*.{ex,exs,heex}",
    "{config,lib,test}/**/*.{ex,exs,heex}",
    "priv/*/seeds.exs"
  ]
]
