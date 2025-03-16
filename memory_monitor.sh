# Script to check the available free memory on the system and alert the user if it falls below a threshold

#!/bin/bash

# Variables
THRESHOLD=500  # Set the threshold in MB (e.g., 500 MB)
ALERT_EMAIL="user@example.com"  # Replace with your email address for alerts
LOG_FILE="/var/log/memory_monitor.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Get available free memory in MB
AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')

# Check if available memory is below the threshold
if [ "$AVAILABLE_MEM" -lt "$THRESHOLD" ]; then
    ALERT_MESSAGE="Warning: Available memory is below the threshold! Free memory: ${AVAILABLE_MEM}MB"
    log_message "$ALERT_MESSAGE"
    
    # Send an alert (e.g., via email or terminal)
    echo "$ALERT_MESSAGE" | mail -s "Memory Alert on $(hostname)" "$ALERT_EMAIL"
    echo "$ALERT_MESSAGE"  # Print to terminal (optional)
else
    log_message "Memory is sufficient. Free memory: ${AVAILABLE_MEM}MB"
fi

# To run the script every 10 minutes:
*/10 * * * * /path/to/memory_monitor.sh

# To edit your crontab:
crontab -e