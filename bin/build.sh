#!/bin/bash

set -euo pipefail

mix local.hex --force
mix deps.get
mix deps.compile
mix escript.build

mv representer ./bin/elixir_representer
chmod +x ./bin/elixir_representer
