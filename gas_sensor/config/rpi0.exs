import Config

# This is our custom configuration for this project running on rpi0:
config :gas_sensor,
  i2c_bus: "i2c-1",
  bme680_module: BMP280,
  temp_path: "/sys/class/thermal/thermal_zone0/temp",
  env: :rpi0, # this is for picking the correct time if we are running on rasberry pi. Look inside the GasSensor.Timestamp module
  config: "/data/offset_config.json"  # this is for setting and saving the vsensor offset_config on the rasberry pi, look
                                      # in GasSensor.ConfigManager

