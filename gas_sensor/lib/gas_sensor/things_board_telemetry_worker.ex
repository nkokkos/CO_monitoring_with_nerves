defmodule GasSensor.TelemetryThingsboard do
  use GenServer
  require Logger

  # What are we doing here:

  # Every 15 seconds, we read from the ReadingAgent and we send out the information to the
  # thingsboard api

  # This is bad practice but anyway: I have hardcoded the telemetry period of 15 seconds = 15_000

  # use example from here
  # https://github.com/gausby/tortoise
  # https://www.codesync.global/uploads/media/activity_slides/0001/02/4f9231e35e2afeb0a669389afea70bec0be84863.pdf
  # https://www.codesync.global/media/tortoise-evolved-mqtt-5-support-in-tortoise-mqtt-client/

  # implement these too in the future
  # try also these examples from here:
  # https://github.com/emqx/emqtt
  # https://www.emqx.com/en/blog/mqtt-for-elixir

  # Need to include the nerves key for X.509 certificates. 
  # Right now, this thing works with simple access token

  # Constants from your mosquitto_pub example
  @client_id "gas_sensor_001"
  @host "mqtt.eu.thingsboard.cloud"
  @port 1883
  #@access_token "add_the_access_token_here"
  @topic "v1/devices/me/telemetry"

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  def init(_opts) do
   
    # load the access token from .env file:
    access_token = Application.get_env(:gas_sensor, :tb_access_token)

    # Start MQTT connection
    case Tortoise.Supervisor.start_child(
      client_id: @client_id,
      handler: {Tortoise.Handler.Default, []},
      server: {Tortoise.Transport.Tcp, host: @host, port: @port},
      user_name: access_token
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

  @impl true
  def handle_info(:send_telemetry, state) do

    # example:
    # payload = Jason.encode!(%{voltage: 3.335, status: "active"})

    # read latest data from the ReadingAgent
    data_point = GasSensor.ReadingAgent.get_reading()
    
    # remove the i2c key from the agent since we do not need it. PLus, 
    # it breaks up json encoding
    data_point_without_i2c = Map.delete(data_point, :i2c)

    payload = Jason.encode!(data_point_without_i2c)

    case Tortoise.publish(@client_id, @topic, payload, qos: 1) do
      #qos:1  returns a reference:
      {:ok, _ref} -> Logger.info("Telemetry published, waiting for ack...")
      {:error, reason} -> Logger.error("Publish failed: #{inspect(reason)}")
    end
    
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :send_telemetry, 15_000)
  end

  #confirmation from Tortoise and thingsboard:
  @impl true
  def handle_info({{Tortoise, @client_id}, _ref, :ok}, state) do
    Logger.debug("Broker confirmed message delivery.")
    {:noreply, state}
  end

   #from documentation these are the mqtte callback handlers:

   #@impl true
   #def handle_info({{Tortoise, @client_id}, _ref, :ok}, state) do
   # # We just acknowledge this so the GenServer doesn't crash.
   # {:noreply, state}
   #end

   #@impl true
   #def handle_info({{Tortoise, @client_id}, _ref, {:error, reason}}, state) do
   #Logger.error("MQTT publish was rejected by broker: #{inspect(reason)}")
   #{:noreply, state}
   #end


end
