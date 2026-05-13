import Config

# Development configuration
#config :gas_sensor_web, GasSensorWeb.Endpoint,
#  http: [ip: {0, 0, 0, 0}, port: 3001],
#  check_origin: false,
#  code_reloader: true,
#  debug_errors: true,
#  secret_key_base: "SDr2csjko/PTHvW/YRWIIV4I3LNE8sjyUU9iigvoKW6z+SlnmYdoZ044a26adLBP",
#  watchers: [], 
#  server: true

# the top-level application always wins.
# This for the case, we we run in dev mode on local and we 
# use gas_sensor as dependency

# this should be loaded when we are running on host
config :gas_sensor,
  i2c_bus: "i2c-bus_stub",                       # the bus should be stubbed too.
  bme680_module: GasSensor.BME680.Stub,          # use stub in tests, not real sensor
  temp_path: "/tmp/thermal/thermal_zone0/temp",  # when testing on the host machine, make sure this file exists in you linux system:
  env: :host,                                    # This is for running on host, only for this OTP app. For GasSensor.Timestamp
  config: "/tmp/offset_config.json"              # This is for running on host, should create the file on linux on /tmp

config :gas_sensor_web, GasSensorWeb.Endpoint,
  # 1. Identity for links
  url: [host: "localhost", port: 3001],
  
  # 2. Open the door for VirtualBox (0.0.0.0)
  http: [ip: {0, 0, 0, 0}, port: 3001],
  
  # 3. The 64-byte key (Fixed)
  secret_key_base: "SDr2csjko/PTHvW/YRWIIV4I3LNE8sjyUU9iigvoKW6z+SlnmYdoZ044a26adLBP",
  
  # 4. The LiveView "Glue" (Crucial for Vagrant)
  check_origin: false,
  
  # 5. Infrastructure
  adapter: Bandit.PhoenixAdapter,
  code_reloader: true,
  debug_errors: true,
  live_view: [signing_salt: "gas_sensor_web_salt"],
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true
