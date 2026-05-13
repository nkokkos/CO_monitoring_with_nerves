# gas_sensor/config/config.exs
import Config

# Keep in mind that:
# MIX_TARGET=host - the host mode or laptop mode
# Files Loaded: config.exs → host.exs.

# MIX_TARGET=rpi0 (The "Embedded" Mode)
# Files Loaded: config.exs → target.exs → rpi0.exs

# If you run tests or compile on host 
# then the keys :gas_sensor apply here only on this
# otp app: gas_sensor

# Note the differences between compile_env and get_env:

# compile_env -> baked into bytecode at mix compile time
# use for things that NEVER change per device
# for this example, this must be at 
# the application.ex file:
# @bme680 Application.compile_env(:gas_sensor, :bme680_module, BMP280)

# get_env -> read at runtime when app boots
# use for things that COULD change per device
# example: i2c_bus = Application.get_env(:gas_sensor, :i2c_bus, "i2c-1")

# Picks ups configuration based on the host
# What it does: host.exs contains settings for our host(laptop). For
# example using a fake Mock sensor
# Target.exs contains settings for the PI zero like wifi credentials, I2C bus
# addresses for the devices we will use
if Mix.target() == :host do
  import_config "host.exs"
else
  import_config "target.exs"
end
 
