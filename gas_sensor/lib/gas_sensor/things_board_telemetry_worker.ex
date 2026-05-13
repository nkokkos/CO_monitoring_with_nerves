defmodule GasSensor.TelemetryThingsboard do
  use GenServer
  require Logger


  # use example from here
  # https://github.com/gausby/tortoise
  # https://www.codesync.global/uploads/media/activity_slides/0001/02/4f9231e35e2afeb0a669389afea70bec0be84863.pdf
  # https://www.codesync.global/media/tortoise-evolved-mqtt-5-support-in-tortoise-mqtt-client/


  # try these examples from here:
  # https://github.com/emqx/emqtt
  # https://www.emqx.com/en/blog/mqtt-for-elixir


  # Constants from your mosquitto_pub example
  
  @client_id "gas_sensor_001"
  @host "mqtt.eu.thingsboard.cloud"
  @port 1883
  @access_token "your_device_token_here"
  @topic "v1/devices/me/telemetry"

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  def init(_opts) do
    # Start MQTT connection
    case Tortoise.Supervisor.start_child(
      client_id: @client_id,
      handler: {Tortoise.Handler.Default, []},
      server: {Tortoise.Transport.Tcp, host: @host, port: @port},
      user_name: @access_token
    ) do
      {:ok, _pid} -> 
        Logger.info("MQTT client started")
        schedule_work()
        {:ok, %{}}
      
      {:error, reason} ->
        Logger.error("Failed to start MQTT: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  def handle_info(:send_telemetry, state) do
    payload = Jason.encode!(%{voltage: 3.335, status: "active"})
    
    case Tortoise.publish(@client_id, @topic, payload, qos: 1) do
      :ok ->
        Logger.info("Telemetry sent: #{payload}")

      {:error, :unknown_client} ->
        Logger.warning("MQTT client not ready, retrying...")

      {:error, reason} ->
        Logger.error("Publish failed: #{inspect(reason)}")
    end
    
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :send_telemetry, 15_000)
  end

end
