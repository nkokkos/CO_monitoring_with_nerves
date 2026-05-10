#!/bin/bash
#rm -rf _build
#rm -rf deps
rm -rf priv/static/assets
mix deps.get
mix assets.build
mix assets.deploy
mix phx.server
