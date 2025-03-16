#Shell script to fetch logs from a remote server, analyze them for error messages, and generate a summary report. The script uses scp to fetch the logs and grep to analyze them for errors.

#!/bin/bash

# Variables
REMOTE_USER="user"                  # Remote server username
REMOTE_HOST="remote.example.com"    # Remote server hostname or IP
REMOTE_LOG_DIR="/var/log"           # Remote directory containing logs
LOCAL_LOG_DIR="/tmp/remote_logs"    # Local directory to store fetched logs
LOG_FILE="/var/log/log_analysis.log"
ERROR_PATTERNS=("ERROR" "FATAL" "CRITICAL")  # Patterns to search for in logs

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Ensure local directory exists
mkdir -p "$LOCAL_LOG_DIR"

# Fetch logs from the remote server
log_message "Fetching logs from $REMOTE_USER@$REMOTE_HOST:$REMOTE_LOG_DIR..."
scp "$REMOTE_USER@$REMOTE_HOST:$REMOTE_LOG_DIR/*.log" "$LOCAL_LOG_DIR/"

if [ $? -ne 0 ]; then
    log_message "Error: Failed to fetch logs from remote server."
    exit 1
fi

# Analyze logs for error messages
log_message "Analyzing logs for error patterns..."
for pattern in "${ERROR_PATTERNS[@]}"; do
    log_message "Searching for pattern: $pattern"
    grep -i "$pattern" "$LOCAL_LOG_DIR"/*.log >> "$LOCAL_LOG_DIR/error_summary.txt"
done

# Generate a summary report
SUMMARY_FILE="$LOCAL_LOG_DIR/error_summary.txt"
if [ -s "$SUMMARY_FILE" ]; then
    log_message "Error summary report generated: $SUMMARY_FILE"
    echo "=== Error Summary Report ==="
    echo "Errors found in the following logs:"
    echo "-----------------------------"
    cat "$SUMMARY_FILE"
else
    log_message "No errors found in the logs."
    echo "No errors found in the logs."
fi

log_message "Log analysis completed."

<< 'Comment'
Explanation:
REMOTE_USER: The username for the remote server.
REMOTE_HOST: The hostname or IP address of the remote server.
REMOTE_LOG_DIR: The directory on the remote server where logs are stored.
LOCAL_LOG_DIR: The local directory where logs will be stored temporarily.
ERROR_PATTERNS: An array of patterns to search for in the logs (e.g., "ERROR", "FATAL", "CRITICAL").
scp: Fetches logs from the remote server to the local directory.
grep: Searches for error patterns in the logs and saves the results to a summary file.
log_message: Logs messages with a timestamp to the specified log file.
Comment

#If the logs are large, consider compressing them on the remote server before fetching:
ssh "$REMOTE_USER@$REMOTE_HOST" "tar -czf /tmp/logs.tar.gz $REMOTE_LOG_DIR/*.log"
scp "$REMOTE_USER@$REMOTE_HOST:/tmp/logs.tar.gz" "$LOCAL_LOG_DIR/"
tar -xzf "$LOCAL_LOG_DIR/logs.tar.gz" -C "$LOCAL_LOG_DIR/"