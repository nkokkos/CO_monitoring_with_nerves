# My thoughts: there should be a way to define a default value 
# for the zero CO calibration value which is the
# voltage produced when the gas sensor is in clean air.
# I call that value volt_zero.
# The idea is that you take that value and you insert
# it into the sensor genserver to start counting ppm
# from zero. It get reads everytime the reading agent starts

defmodule GasSensor.ConfigManager do 

  require Logger
  
  # load the load file based on configuration.
  @config_file Application.get_env(:gas_sensor, :config)
  
  @default_offset 0.0
  @default_config %{"vsensor_offset" => 0.0}

  def init() do
    if @config_file == nil do
      Logger.error("Config file path is nil! Check your config.exs or Nerves environment.")
      @default_config
    else 
      case File.read(@config_file) do
        {:ok, content} -> 
          content 
          |> Jason.decode!() 

        {:error, :enoent} ->
          File.mkdir_p!(Path.dirname(@config_file))
          save_vsensor_offset(@default_config)
          @default_config 
      end
    end
  end

  def save_vsensor_offset(value) do 
    # build the config and save it to file
    config = %{"vsensor_offset" => value}
    File.write!(@config_file, Jason.encode!(config, pretty: true))
  end
    
  def get_vsensor_offset do
    case File.read(@config_file) do
      {:ok, content} -> 
        content 
        |> Jason.decode!() 

       {:error, :enoent} ->
         @default_config
    end
  end

end

 
