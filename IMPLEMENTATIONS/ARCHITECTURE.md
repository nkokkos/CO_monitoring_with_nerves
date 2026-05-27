# Gas Sensor Poncho Project - Architecture Documentation

## Overview

This project uses a **three-layer poncho architecture** with proper separation of concerns:

1. **Hardware Layer** (`gas_sensor`) - I2C sensor reading
2. **Cache Layer** (`gas_sensor.ReadingAgent`) - Non-blocking data access
3. **Interface Layer** (`gas_sensor_web`) - Phoenix web interface

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────┐
│                    Phoenix LiveView                        │
│                    (Dashboard & Sensor Page)               │
│                          │                                 │
│                          │ reads from                      │
│                          ▼                                 │
│              ┌─────────────────────────┐                   │
│              │   ReadingAgent.get/0    │                   │
│              └───────────┬─────────────┘                   │
└──────────────────────────┼─────────────────────────────────┘
                           │
                           │ updates after each reading
                           │
┌──────────────────────────┼─────────────────────────────────┐
│              ┌───────────┴─────────────┐                   │
│              │   ReadingAgent.update/1 │                   │
│              └───────────┬─────────────┘                   │
│                          │                                 │
│                    GasSensor.Sensor                        │
│             (GenServer - SINGLE I2C WRITER)                │
│                          │                                 │
│                          │ exclusive access                │
│                          ▼                                 │
│                    ┌─────────────┐                         │
│                    │   I2C Bus   │ ◄─── (ADS1115)          |
│                    │   i2c-1     │ ◄─── (BME680)           |
│                    └─────────────┘ ◄───  Nerves Key        │
└────────────────────────────────────────────────────────────┘
```

## Key Design Decisions

### 1. Agent Pattern for Reading Storage

**Why use an Agent?**

- **Prevents I2C Contention**: Only the Sensor GenServer touches the I2C bus
- **Non-blocking Reads**: Web requests never wait for I2C operations (125ms per read)
- **Fault Isolation**: Web interface continues working with last known value if sensor fails
- **Better Concurrency**: Multiple web requests can read simultaneously

**Data Flow:**
1. Sensor reads from I2C 15 seconds
2. Sensor calculates median from 7 in series samples
3. Sensor pushes result to Agent (with timestamp)
4. Phoenix reads from Agent instantly (no blocking)

### 2. Supervision Tree Order

The supervision trees are designed to ensure proper startup order:

**gas_sensor supervision tree:**
```
Supervisor (one_for_one)
├── GasSensor.ReadingAgent (starts first - no deps)
└── GasSensor.Sensor (starts second - updates Agent)
```

**Complete system supervision:**
```
Nerves Firmware
├── GasSensor OTP App (auto-starts)
│   ├── ReadingAgent
│   └── Sensor (I2C hardware)
├── GasSensorWeb OTP App (auto-starts)
│   ├── PubSub
│   ├── Telemetry
│   └── Endpoint (HTTP server)
└── sampler OTP App (minimal - just for coordination)
```

### 3. I2C Bus Isolation

**Critical Design Rule**: Only `GasSensor.Sensor` ever calls `Circuits.I2C`

This prevents:
- Race conditions on I2C bus
- Interleaved transactions
- Timeout errors from concurrent access

### 4. Configuration Strategy

Configuration is split by environment:

- **host.exs**: Development/testing (no I2C hardware)
- **target.exs**: Production Pi Zero W (with I2C and WiFi)


## API Reference

### ReadingAgent API

```elixir
# Non-blocking reads (use these in web interface)
Core.ReadingAgent.get_reading()   # Get full reading map
Core.ReadingAgent.get_ppm()       # Get just PPM value
Core.ReadingAgent.get_status()    # Get status atom

# Internal use only (called by Sensor)
Core.ReadingAgent.update(reading_map)  # Push new reading
```

## Testing Strategy

### Host Development

```bash
# Test business logic
cd gas_sensor
mix test

# Test web interface (I2C fails gracefully)
cd gas_sensor_web
mix phx.server
# Agent returns default values (ppm: 0.0, status: :not_started)
```

### Target Testing

```bash
# Build and deploy
cd sampler
export MIX_TARGET=rpi0
mix deps.get
mix firmware
mix burn

# On device, verify with IEx
GasSensor.ReadingAgent.get_reading()
# Should show real readings from I2C sensor
```

## Performance Characteristics

### I2C Timing
- Sampling interval:  (7 samples over 15 seconds)

### Agent Performance
- Read operation: O(1) - constant time, no blocking
- Update operation: O(1) - constant time

## Fault Tolerance

### Sensor Failure
1. Sensor GenServer crashes
2. Supervisor restarts it
3. ReadingAgent still holds last known value
4. Web interface continues serving stale data
5. Status changes to `:error`

### Agent Failure
1. Agent crashes
2. Supervisor restarts it
3. Agent returns to default state
4. Sensor continues updating (I2C unaffected)
5. Web shows `:not_started` until next update

### I2C Bus Error
1. I2C read fails
2. Sensor updates Agent with `:error` status
3. Sensor continues retrying
4. Web interface shows error state
5. No web request ever touches I2C

## Best Practices Used

1. **Single Responsibility**: Each module has one clear job
2. **Dependency Inversion**: Web depends on Agent, not directly on I2C
3. **Fault Isolation**: Layers fail independently
4. **Non-blocking I/O**: No web request waits for hardware
5. **Supervision Trees**: Proper OTP supervision for all processes
6. **Configuration Separation**: Host vs Target configs
7. **Documentation**: Architecture documented inline

## Conclusion

This architecture ensures:
- ✅ No I2C contention
- ✅ Fast, responsive web interface
- ✅ Fault tolerance at each layer
- ✅ Clean separation of concerns
- ✅ Easy testing and debugging
- ✅ Production-ready for Pi Zero W
