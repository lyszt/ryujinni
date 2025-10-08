rm -rf _build
mix deps.clean --all
mix deps.get && mix compile
mix deps.update --all
