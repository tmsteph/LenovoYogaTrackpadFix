#!/bin/bash

# Check if xprintidle is installed and install if necessary
if ! command -v xprintidle >/dev/null 2>&1; then
    echo "xprintidle is not installed. Attempting to install."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y xprintidle
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y xprintidle
    elif command -v pacman >/dev/null 2>&1; then
        yay -S xprintidle
    else
        echo "Could not detect package manager. Please install xprintidle manually."
        exit 1
    fi
fi

# Create systemd service file to run the script at startup
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root to install the systemd service."
    exit 1
fi

service_file="/etc/systemd/system/toggle-touchpad.service"
script_path="/usr/local/bin/toggle-touchpad.sh"

# Create the script that toggles the touchpad
echo "#!/bin/bash
while true; do
    idle_time_ms=\$(xprintidle)
    idle_time_s=\$((idle_time_ms / 1000))

    if [ \$idle_time_s -ge .1 ]; then
        xinput set-prop 19 \"Device Enabled\" 0
        sleep 0.1
        xinput set-prop 19 \"Device Enabled\" 1
    fi
    sleep .5
done" > "$script_path"

# Make the script executable
chmod +x "$script_path"

# Create the service file
echo "[Unit]
Description=Toggle touchpad

[Service]
ExecStart=$script_path

[Install]
WantedBy=default.target" > "$service_file"

# Reload systemd manager configuration
systemctl daemon-reload

# Enable the service to start at boot
systemctl enable toggle-touchpad

echo "Installed toggle-touchpad service."

