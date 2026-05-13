import Config

# this should be loaded when we are running on host
config :gas_sensor,
  i2c_bus: "i2c-bus_stub",                       # the bus should be stubbed too.
  bme680_module: GasSensor.BME680.Stub,          # use stub in tests, not real sensor
  temp_path: "/tmp/thermal/thermal_zone0/temp",  # when testing on the host machine, make sure this file exists in you linux system:
  env: :host,                                    # This is for running on host, only for this OTP app. For GasSensor.Timestamp
  config: "/tmp/offset_config.json"              # This is for running on host, should create the file on linux on /tmp

