#!/bin/bash

# Remember that to run this when running on dev 
# mode. This ui app depends on gas_sensor, so 
# make sure you force compile it.
# If I am ready to do mix firmmware in the firmware directory
# make sure that gas_sensor app is not included as 
# a dependency into the mix.exs file of this ui app.

rm -rf _build
rm -rf deps
rm -rf priv/static/assets
export MIX_TARGET=host
mix deps.get
mix assets.build
mix assets.deploy
mix deps.compile --force
mix deps.compile gas_sensor --force
iex -S mix phx.server
