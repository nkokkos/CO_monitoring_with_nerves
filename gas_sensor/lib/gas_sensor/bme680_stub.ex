defmodule GasSensor.BME680_Stub do

  use GenServer # <--- Don't forget this!!! CRITICAL: Adds child_spec and GenServer behavior

  @moduledoc """
  Provides realistic random stub data for simulating the BME680 breakout board.
  Useful for testing Phoenix/Livebook visualizations and ThingsBoard logic.
  """
 
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # This sets up the initial "state" of your fake sensor
  @impl true
  def init(opts) do
    {:ok, opts}
  end
  
  # Change measure to a GenServer call
  def measure(server \\ __MODULE__) do
    GenServer.call(server, :measure)
  end

  @impl true
  def handle_call(:measure, _from, state) do
    temp = 22.0 + (:rand.uniform() - 0.5)
    hum = 55.0 + (:rand.uniform() * 2 - 1)
    gas_res = 5578.28 + (:rand.uniform() * 500 - 250)

    reading = %{
      temperature_c: Float.round(temp, 2),
      humidity_rh: Float.round(hum, 2),
      dew_point_c: 12.5,
      gas_resistance_ohms: gas_res,
      pressure_pa: 101_325.0 + :rand.uniform(10),
      timestamp_ms: System.monotonic_time(:millisecond)
    }

    {:reply, {:ok, reading}, state}
  end


  # don't need this for our stub case
  # def force_altitude(_server, _altitude), do: :ok

end
