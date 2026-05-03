defmodule GasSensor.Timestamp do
  @moduledoc """
  Reliable UTC timestamp generation for RTC-less embedded systems.

  Handles two critical scenarios on Raspberry Pi Zero W:
  1. **Normal boot with WiFi:** NTP syncs within 60 seconds → accurate timestamps
  2. **Offline/no WiFi:** Time stays at 1970 or build date → provisional timestamps

  ## Usage

      # Get timestamp with reliability check
      {timestamp, reliable?} = GasSensor.Timestamp.now_with_reliability()
      
      # Check NTP sync status
      synced? = GasSensor.Timestamp.ntp_synced?()
      
      # Check if we're in offline mode
      offline? = GasSensor.Timestamp.offline_mode?()
      
      # Get provisional timestamp (for offline data)
      timestamp = GasSensor.Timestamp.provisional_timestamp()
  """

  require Logger
     
  @minimum_reliable_year 2025

  def now_with_reliability do
    ts = DateTime.utc_now()
    if reliable_time?(ts) do
      {ts, true}
    else
      {provisional_timestamp(), false}
    end
  end

  def now do
    DateTime.utc_now()
  end

  def ntp_synced? do
    reliable_time?(DateTime.utc_now())
  end

  def offline_mode? do
    not ntp_synced?()
  end

  def provisional_timestamp do
    elapsed_sec = System.monotonic_time(:second)
    DateTime.add(GasSensor.Application.build_date(), elapsed_sec)
  end

  # Private

  defp reliable_time?(%DateTime{year: year}) do
    year >= @minimum_reliable_year
  end

end
