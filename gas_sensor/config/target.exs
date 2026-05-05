import Config

# configure Nerves Time:
# Basically, block device startup for 5 seconds waiting for NTP response
config :nerves_time, await_initialization_timeout: :timer.seconds(5)

# Configure NTP servers for time synchronization
# These are used by nerves_time to sync system clock
# You can specify custom servers here (e.g., your own NTP server)
config :nerves_time, :servers, [
  # Default NTP pool servers (recommended for most users)
  "0.pool.ntp.org",
  "1.pool.ntp.org",
  "2.pool.ntp.org",
  "3.pool.ntp.org"

  # Regional servers (uncomment for better performance in your region)
  # "0.us.pool.ntp.org",        # North America
  # "0.europe.pool.ntp.org",    # Europe
  # "0.asia.pool.ntp.org",      # Asia

  # Custom/internal NTP servers (add your own)
  # "ntp.mycompany.local",      # Internal company server
  # "192.168.1.1",              # Router with NTP
  # "10.0.0.1",                 # Local network NTP
]

