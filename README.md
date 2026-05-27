## Carbon Monoxide Monitoring with TGS5042 Sensor and Elixir Nerves

## This is an Elixir Nerves [poncho project](https://embedded-elixir.com/post/2017-05-19-poncho-projects/)  Project that samples CO from a TGS5042 sensor.

## Target Platform

**Raspberry Pi Zero W** - The firmware is specifically built for this platform.

## Project Structure

```
├── firmware/                   # Nerves firmware application
├── gas_sensor/                 # OTP business logic
└── gas_sensor_web/             # Phoenix web interface
```

### Upgrade you elixir nerves 

```bash
mix local.hex
mix local.rebar
mix archive.install hex nerves_bootstrap
```

### 1. Build and test the gas sensor library

```bash
cd firmware
mix deps.get
mix test
```

### 2. Build firmware for Raspberry Pi Zero W

```bash
cd firmware
export MIX_TARGET=rpi0
mix deps.get
mix firmware
```

### 3. Deploy to SD card

Insert your SD card and run:

```bash
mix burn
```

## Web Interface

The project includes a Phoenix web interface accessible once the device is on WiFi:

- **Dashboard** (`http://<device-ip>/`) - Overview with visual PPM indicators
- **Detailed View** (`http://<device-ip>/sensor`) - Live sensor data with sample history
- **API** (`http://<device-ip>/api/readings/current`) - JSON API for integrations

The web interface updates in real-time using Phoenix LiveView (1-second refresh).

## Hardware Setup

### Components

- **Raspberry Pi Zero W** (with wireless)
- ADS1115 ADC connected via I2C
- TGS 5042 Gas sensor (CO sensor with known sensitivity)
- Micro USB power supply

### Wiring

```
ADS1115      ->   Pi Zero W
-------          ---------
VDD          ->   3.3V (Pin 1)
GND          ->   GND  (Pin 6)
SDA          ->   GPIO 2 (Pin 3, I2C SDA)
SCL          ->   GPIO 3 (Pin 5, I2C SCL)
ADDR         ->   GND  (for address 0x48)
```

Connect your gas sensor output to ADS1115 AIN0/AIN1 for differential reading.

### I2C Address

Default: `0x48` (ADDR pin to GND)

## WiFi Configuration

```elixir
VintageNet.configure("wlan0", %{
  type: VintageNetWiFi,
  vintage_net_wifi: %{
    networks: [%{
      ssid: "YOUR_WIFI_SSID",
      psk: "YOUR_WIFI_PASSWORD",
      key_mgmt: :wpa_psk
    }]
  },
  ipv4: %{method: :dhcp}
})
```

## Architecture

### Firmware OTP Application

A reusable OTP application that provides:

- **GasSensor.Sensor** - GenServer that:
  - Communicates with ADS1115 ADC via I2C
  - Samples 11 times over 10 seconds
  - Applies median filtering
  - Calculates CO concentration in PPM
  - Provides `get_ppm/0` and `get_state/0` APIs

Key features:
- Fault-tolerant (supervised restart on failure)
- Configurable I2C bus
- Calibrated for specific gas sensor
- Logging for debugging

### GasSensorWeb Phoenix Application

A lightweight Phoenix web interface that:

- **DashboardLive** (`/`) - Overview dashboard with:
  - Large PPM display with color-coded indicators
  - Air quality levels legend
  - Live update status
  
- **SensorLive** (`/sensor`) - Detailed view with:
  - Current PPM with status badge
  - Sample count and window size
  - Recent sample history (last 7 samples)
  
- **SensorController** - JSON API:
  - `GET /api/readings` - All available readings
  - `GET /api/readings/current` - Current reading only

Features:
- Real-time updates via LiveView (1-second polling)
- Minimal dependencies (Bandit web server, no database)
- Embedded CSS (no external assets needed)
- Mobile-responsive design

### Firmware Nerves Application

Firmware that:
- Runs on Raspberry Pi Zero W
- Configures WiFi networking
- Starts Core OTP app for I2C readings
- Starts UI Phoenix app for web interface
- Provides IEx helpers for interactive debugging

## Calibration

Edit `gas_sensor/lib/gas_sensor/sensor.ex` and update these values based on your sensor datasheet:

```elixir
# Sensor calibration constants
@sensitivity_na_per_ppm 1.525    # nA per ppm (from sensor label/datasheet)
@r3_ohms 1_200_000               # Feedback resistor value
@divider_factor 2.0              # Voltage divider factor
```

## Usage

### Interactive Shell (IEx)

Connect to your Pi Zero W via serial console or SSH, then:

```elixir
# Get current PPM reading
GasSensor.Sensor.get_ppm()

# Get full state for debugging
GasSensor.Sensor.get_state()

```

### Web Interface

Once connected to WiFi, access the web interface:

1. Find the device IP (check your router or use `hostname -I` in IEx)
2. Open browser to `http://<device-ip>`
3. View real-time sensor readings

### From Your Code

```elixir
# The sensor is automatically supervised and started
# Just call the API:
ppm = GasSensor.Sensor.get_ppm()
Logger.info("Current CO level: #{ppm} ppm")
```

## Development on Host

```bash
# Test business logic
cd gas_sensor
mix test

# Test web interface (without I2C hardware)
cd gas_sensor_web
mix phx.server
# Access at http://localhost:4000
```

## Pi Zero W Specific Notes

- **Power**: Use a good quality 2.5A+ power supply
- **I2C**: Enabled by default in Nerves systems
- **GPIO**: I2C pins are GPIO 2 (SDA) and GPIO 3 (SCL)
- **WiFi**: 2.4GHz only (802.11n)
- **Headless**: Designed to run without monitor/keyboard
- **Web Server**: Runs on port 80 (http://device-ip/)

## Dependencies

- [Nerves](https://hexdocs.pm/nerves) - Embedded framework
- [Nerves System RPi0](https://hexdocs.pm/nerves_system_rpi0) - Pi Zero W system
- [Circuits I2C](https://hexdocs.pm/circuits_i2c) - I2C communication
- [VintageNet](https://hexdocs.pm/vintage_net) - Networking
- [Phoenix](https://hexdocs.pm/phoenix) - Web framework
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view) - Real-time UI

## References

- [ADS1115 Datasheet](https://www.ti.com/lit/ds/symlink/ads1115.pdf)
- [Nerves Project](https://nerves-project.org/)
- [Nerves Pi Zero System](https://github.com/nerves-project/nerves_system_rpi0)
- [Poncho Projects](https://embedded-elixir.com/post/2017-05-19-poncho-projects/)
- [Phoenix Framework](https://phoenixframework.org/)


---

## ⚠️ Disclaimer & Safety Warning

> **THIS IS A PROOF-OF-CONCEPT PROJECT. IT WILL NOT SAVE YOUR LIFE.**

### 🚫 NOT a Safety Device
This project **must not** be used as:
- A certified carbon monoxide alarm
- A life-safety or emergency detection system
- A replacement for any certified CO detector

**If you need CO protection, buy a certified alarm (UL 2034 / EN 50291).**

### 🎓 Purpose
This is a personal research project, open-sourced to share knowledge with the embedded systems and Elixir/Nerves community. It demonstrates ADC reading, signal processing, and IoT architecture — nothing more.

### 📋 No Certification
This project has **not** been tested or certified by:
- Underwriters Laboratories (UL)
- CE / EN standards bodies
- Any regulatory safety authority

Sensor calibration is approximate and based on datasheet values only.


> * **Educational & Research Purposes:** This project is the result of personal/academic research. It is made open-source in good faith, with the sole intention of sharing knowledge and contributing to the open-science community.
> * **NOT A LIFE-SAVING DEVICE:** This system **MUST NOT**, under any circumstances, be used as a life-saving apparatus, commercial safety device, or official carbon monoxide alarm. 
> * **No Certification or Calibration:** The hardware and software components used in this project have **NOT** been certified by Underwriters Laboratories (UL), CE, or any other regulatory safety standards. The analog circuit and software calibration applied here are intended *only* to demonstrate a proof-of-concept architecture and have not undergone the rigorous testing required for safety-critical deployment.
> * **No Liability:** This software and hardware design are provided "AS IS", without warranty of any kind, express or implied. In no event shall I, the author, be held liable for any claim, damages, or other liability, including but not limited to personal injury, property damage, or loss of life, arising from the use or misuse of this project.
>
> **By exploring or replicating this project, you accept full responsibility for any risks involved.**

---

## 📄 License

This project is licensed under the MIT License - see below for details:

```text
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
