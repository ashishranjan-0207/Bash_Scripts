# Script to monitor the network connectivity of a server and log the results if it is unreachable.

#!/bin/bash

# Variables
SERVER_IP="192.168.1.1"  # Replace with your server's IP address or hostname
LOG_FILE="/var/log/network_monitor.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check connectivity
ping -c 1 "$SERVER_IP" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    log_message "Server $SERVER_IP is unreachable."
else
    log_message "Server $SERVER_IP is reachable."
fi

# To run the script every 5 minutes, you can add the following line to your crontab:
*/5 * * * * /path/to/network_monitor.sh

# To edit crontab:
crontab -e