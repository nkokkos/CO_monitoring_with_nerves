# Elixir Nerves commands 
``
Application.started_applications
top()
cmd("free") or :erlang.memory()
VintageNet.info()
VintageNet.all_interfaces()
```

# Check all environment in the firmare:
```
Application.get_all_env(:firmware)
 ```

# Supervisor
```
example:
Supervisor.which_children(GasSensor.Supervisor)
```

# Check ETS memory usage
```
:ets.info(:your_table_name, :memory) * 8 / 1024 / 1024  # MB
```

# Check total memory
```
:erlang.memory()
```

# Async threads
```
:erlang.system_info(:thread_pool_size)i
```

# Upgrade Nerves
```
mix local.hex --force
mix local.rebar --force 
mix archive.install hex nerves_bootstrap --force
```

# Check for firmware version on boot
```
Nerves.Runtime.KV.get_active("nerves_fw_version")
```

