#This script provides a simple way to monitor disk space usage across multiple servers and send alerts if the usage exceeds a specified threshold. Customize it further based on your specific requirements.

#!/bin/bash

# Variables
THRESHOLD=80  # Disk usage threshold in percentage
LOG_FILE="/var/log/disk_space_check.log"
ALERT_EMAIL="admin@example.com"  # Replace with your email address

# List of servers to check (format: "user@hostname")
SERVERS=(
    "user1@server1.example.com"
    "user2@server2.example.com"
    "user3@server3.example.com"
)

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to send an alert email
send_alert() {
    local server=$1
    local usage=$2
    local partition=$3
    echo "Disk usage on $server ($partition) is at ${usage}%, which exceeds the threshold of ${THRESHOLD}%." | mail -s "Disk Space Alert on $server" "$ALERT_EMAIL"
}

# Check disk space on each server
for server in "${SERVERS[@]}"; do
    log_message "Checking disk space on $server..."

    # Get disk usage using SSH
    ssh "$server" "df -h" | awk 'NR>1 {print $5 " " $6}' | while read -r usage partition; do
        usage_percent=${usage%\%}  # Remove the % sign
        if [ "$usage_percent" -ge "$THRESHOLD" ]; then
            alert_message="Disk usage on $server ($partition) is at ${usage}, which exceeds the threshold of ${THRESHOLD}%."
            log_message "$alert_message"
            send_alert "$server" "$usage_percent" "$partition"
        fi
    done
done

log_message "Disk space check completed."

<< 'Comment'
Explanation:
1.THRESHOLD: The disk usage threshold in percentage (e.g., 80%).
2.LOG_FILE: The path to the log file where the results will be stored.
3.ALERT_EMAIL: The email address to which alerts will be sent.
4.SERVERS: An array of servers to check. Each entry should be in the format user@hostname.
5.ssh: Connects to each server and runs the df -h command to check disk usage.
6.awk: Extracts the usage percentage and partition name from the df output.
7.send_alert: Sends an email alert if the disk usage exceeds the threshold.
Comment


