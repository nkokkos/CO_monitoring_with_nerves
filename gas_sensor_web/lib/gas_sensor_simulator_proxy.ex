# This defines GasSensor at the root level so the LiveView can find it.
# We do it so that we can test the simulator on this OTP without needing 
# real data from the the firmware/gas_sensor module

defmodule GasSensor do

  defmodule ReadingAgent do
    # This points the global call to your specific Simulator
    defdelegate get_reading(), to: GasSensorWeb.Simulator.ReadingAgent
    defdelegate get_ppm(), to: GasSensorWeb.Simulator.ReadingAgent
    defdelegate get_status(), to: GasSensorWeb.Simulator.ReadingAgent
  end

  defmodule History do
    defdelegate get_for_graph(max_points), to: GasSensorWeb.Simulator.History
    defdelegate get_last_24h(), to: GasSensorWeb.Simulator.History
    
    # we do this because of this:
    # In Elixir, defdelegate is a "dumb" macro. It doesn't actually execute code or check types. It 
    # just maps a function call from one module to another. Because it’s a shorthand, 
    # it cannot handle pattern matching like %DateTime{} = datetime.
    @doc "Fetches history since a specific DateTime, ensuring type safety"
    def get_since(%DateTime{} = datetime) do
      GasSensorWeb.Simulator.History.get_since(datetime)
    end

  end

  defmodule Timestamp do
    defdelegate now_with_reliability,  to: GasSensorWeb.Simulator.Timestamp
    defdelegate now, to: GasSensorWeb.Simulator.Timestamp
  end

end
