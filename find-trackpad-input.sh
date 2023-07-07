#!/bin/bash

# Replace "Touchpad" with the exact name of your touchpad device
device_name="Touchpad"

while true; do
    idle_time_ms=$(xprintidle)
    idle_time_s=$((idle_time_ms / 1000))

    if [ $idle_time_s -ge 5 ]; then
        # Find the touchpad device ID
        device_id=$(xinput --list | grep "$device_name" | grep -o 'id=[0-9]\+' | grep -o '[0-9]\+')

        if [ -n "$device_id" ]; then
            xinput set-prop $device_id "Device Enabled" 0
            sleep 0.1
            xinput set-prop $device_id "Device Enabled" 1
        fi
    fi
    sleep 1
done

