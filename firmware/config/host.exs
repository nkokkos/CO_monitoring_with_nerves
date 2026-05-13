import Config
# Enter here configuration for running on host
# For example, if you do export MIX_TARGET=host, 
# configuration will be read from this file
#
# Add configuration that is only needed when running on the host here.
#

# this should be loaded when we are running on host
config :gas_sensor,
  i2c_bus: "i2c-bus_stub",                       # the bus should be stubbed too.
  bme680_module: GasSensor.BME680.Stub,          # use stub in tests, not real sensor
  temp_path: "/tmp/thermal/thermal_zone0/temp",  # when testing on the host machine, make sure this file exists in you linux system:
  env: :host,                                    # This is for running on host, only for this OTP app. For GasSensor.Timestamp
  config: "/tmp/offset_config.json"              # This is for running on host, should create the file on linux on /tmp

config :nerves_runtime,
  kv_backend:
    {Nerves.Runtime.KVBackend.InMemory,
     contents: %{
       # The KV store on Nerves systems is typically read from UBoot-env, but
       # this allows us to use a pre-populated InMemory store when running on
       # host for development and testing.
       #
       # https://hexdocs.pm/nerves_runtime/readme.html#using-nerves_runtime-in-tests
       # https://hexdocs.pm/nerves_runtime/readme.html#nerves-system-and-firmware-metadata

       "nerves_fw_active" => "a",
       "a.nerves_fw_architecture" => "generic",
       "a.nerves_fw_description" => "N/A",
       "a.nerves_fw_platform" => "host",
       "a.nerves_fw_version" => "0.0.0"
     }}


