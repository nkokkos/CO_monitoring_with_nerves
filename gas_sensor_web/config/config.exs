# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :gas_sensor_web,
   generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :gas_sensor_web, GasSensorWeb.Endpoint,
  url: [host: "localhost"],
  #cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: "SDr2csjko/PTHvW/YRWIIV4I3LNE8sjyUU9iigvoKW6z+SlnmYdoZ044a26adLBP",
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: GasSensorWeb.ErrorHTML, json: GasSensorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GasSensorWeb.PubSub,
  live_view: [signing_salt: "gas_sensor_web_salt"]


config :esbuild,
  version: "0.25.4",
  gas_sensor_web: [
    args:
      # Change --outdir from .../assets/js to .../assets
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]


# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  gas_sensor_web: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
