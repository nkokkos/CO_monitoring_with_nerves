## Run in Dev mode. This will run the whole system in dev mode. Will load a bandit server at 0.0.0.0:3001 
```
export MIX_TARGET=host
mix deps.get
iex -S mix
```

## Create the firmware
```
export MIX_TARGET=rpi0
mix deps.get
mix firmware
```

## Explore Elixir Nerves commands after having logged into the nerves device
```
Application.started_applications
top()
cmd("free") or :erlang.memory()
VintageNet.info()
VintageNet.all_interfaces()
```

## Check all environment in the firmware:
```
Application.get_all_env(:firmware)
```

## Supervisor
```
example:
Supervisor.which_children(GasSensor.Supervisor)
```

## Check ETS memory usage
```
:ets.info(:your_table_name, :memory) * 8 / 1024 / 1024  # MB
```

## Check total memory
```
:erlang.memory()
```

## Async threads
```
:erlang.system_info(:thread_pool_size)i
```

## Upgrade Nerves
```
mix local.hex --force
mix local.rebar --force 
mix archive.install hex nerves_bootstrap --force
```

## Check for firmware version on boot
```
Nerves.Runtime.KV.get_active("nerves_fw_version")
```

## Include the ThingsBoard API in env file
Create an env file at ../ and you do:
export $(cat ../.env | xargs) && mix firmware

