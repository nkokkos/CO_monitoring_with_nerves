defmodule Firmware.Dummy do
  use GenServer

  @doc """
  Starts the GenServer. 
  The 'value' passed here goes to 'init/1'.
  """
  def start_link(value) do
    GenServer.start_link(__MODULE__, value, name: __MODULE__)
  end

  @impl GenServer
  def init(value) do
    # We just store the value in the state and do nothing else.
    IO.puts("Dummy GenServer started with value: #{inspect(value)}")
    {:ok, %{my_value: value}}
  end
end
