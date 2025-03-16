#shell script to check the uptime of a server and log the time if the uptime is less than 24 hours. The script uses the uptime command to retrieve the server's uptime and logs the results if the uptime is below the threshold.

#!/bin/bash

# Variables
UPTIME_THRESHOLD=86400  # 24 hours in seconds (24 * 60 * 60)
LOG_FILE="/var/log/uptime_check.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Get the server's uptime in seconds
UPTIME_SECONDS=$(awk '{print int($1)}' /proc/uptime)

# Check if uptime is less than the threshold
if [ "$UPTIME_SECONDS" -lt "$UPTIME_THRESHOLD" ]; then
    UPTIME_HUMAN=$(uptime -p)  # Human-readable uptime
    log_message "Server uptime is less than 24 hours. Current uptime: $UPTIME_HUMAN"
else
    log_message "Server uptime is normal. Current uptime: $(uptime -p)"
fi

#Explanation:
#UPTIME_THRESHOLD: The threshold for uptime in seconds (24 hours = 86400 seconds).
#LOG_FILE: The path to the log file where the results will be stored.
#/proc/uptime: The file that contains the system's uptime in seconds.
#uptime -p: Provides a human-readable format for the uptime (e.g., "up 2 hours, 30 minutes").
#log_message: Logs messages with a timestamp to the specified log file.

#If you want to send an alert (e.g., via email) when the uptime is low, you can add the following to the script:
if [ "$UPTIME_SECONDS" -lt "$UPTIME_THRESHOLD" ]; then
    UPTIME_HUMAN=$(uptime -p)
    log_message "Server uptime is less than 24 hours. Current uptime: $UPTIME_HUMAN"
    echo "Server uptime is less than 24 hours. Current uptime: $UPTIME_HUMAN" | mail -s "Uptime Alert on $(hostname)" admin@example.com
fi

#Example Log Output:
#If the uptime is less than 24 hours:
2023-10-15 12:34:56 - Server uptime is less than 24 hours. Current uptime: up 2 hours, 30 minutes

#If the uptime is normal:
2023-10-15 12:34:56 - Server uptime is normal. Current uptime: up 3 days, 5 hours