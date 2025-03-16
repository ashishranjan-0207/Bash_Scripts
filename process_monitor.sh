# Script that monitors the status of a list of processes and restarts them if they are not running.

#!/bin/bash

# List of processes to monitor (replace with your process names or commands)
PROCESS_LIST=("nginx" "mysql" "apache2")

# Function to restart a process
restart_process() {
    local process_name=$1
    echo "Restarting $process_name..."
    systemctl restart "$process_name"  # Use systemctl for services
    # Alternatively, use a custom command to start the process:
    # /path/to/start_script.sh &
}

# Function to check and restart processes
monitor_processes() {
    for process in "${PROCESS_LIST[@]}"; do
        if pgrep -x "$process" > /dev/null; then
            echo "$process is running."
        else
            echo "$process is NOT running. Attempting to restart..."
            restart_process "$process"
        fi
    done
}

# Main loop to monitor processes periodically
while true; do
    monitor_processes
    sleep 60  # Check every 60 seconds (adjust as needed)
done

# Make the script executable:
chmod +x process_monitor.sh

# Run the script in the background:
./process_monitor.sh &

#Output:
# If a process is running:
# nginx is running.
# mysql is running.
# apache2 is running.

# If a process is not running:
# nginx is NOT running. Attempting to restart...
# Restarting nginx...

# Replace systemctl restart with the appropriate command to start your processes if they are not managed by systemd.
# Ensure the script has the necessary permissions to restart processes (e.g., run it as root or with sudo).
# You can add logging to a file by redirecting the output:
./process_monitor.sh >> /var/log/process_monitor.log 2>&1 &

# To stop the script, use pkill or find its process ID and kill it:
pkill -f process_monitor.sh
