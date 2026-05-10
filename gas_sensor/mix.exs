# Run "mix help compile.app" to learn about applications.
# Run "mix help deps" to learn about dependencies.

defmodule GasSensor.MixProject do
  use Mix.Project

  def project do
    [
      app: :gas_sensor,
      version: "0.1.2",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {GasSensor.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end
  
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [ 
      {:circuits_i2c,  "~> 2.0"},
      {:circuits_gpio, "~> 2.1"},

      # Use Bosch barometric pressure sensors in Elixir 
      # use this librar maintained by Frank Hunleth:
      # https://github.com/elixir-sensors/bmp280
      {:bmp280, "~> 0.2" },

      # Since we need Nerves Time on this OTP app, include it here too.
      # NervesTime keeps the system clock on Nerves devices in sync
      # when connected to the network and close to in sync when disconnected.
      {:nerves_time, "~> 0.4.2"},

      # NervesTimeZones provides a way of managing local time on embedded devices.
      {:nerves_time_zones, "~> 0.3.2"},

      # add blinky dependency so it always flashes while the app is up
      # https://github.com/nerves-project/nerves_examples/tree/main/blinky
      # Look into the application.ex to see how it is used
      # {:delux, "~> 0.4.1", targets: :rpi0},
     
      {:jason, "~> 1.4"}     
 
      # add this package https://hex.pm/packages/fostrom
      # {:fostrom, "~> 0.1.0"}
    ]
  end
end
