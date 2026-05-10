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

config :gas_sensor_web,
  voffset_file: "/tmp/voffset_config.json"

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


