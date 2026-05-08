#!/bin/bash
rm -rf priv/static/assets
mix assets.build
mix assets.deploy
mix phx.server
