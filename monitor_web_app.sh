#Shell script to check the status of a web application running on a remote server and restart it if it is down. The script uses curl to check the application's health endpoint and ssh to restart the service if necessary.

#!/bin/bash

# Variables
REMOTE_USER="user"                  # Remote server username
REMOTE_HOST="remote.example.com"    # Remote server hostname or IP
HEALTH_CHECK_URL="http://localhost:8080/health"  # Web app health check URL
SERVICE_NAME="webapp"               # Name of the service to restart
LOG_FILE="/var/log/webapp_monitor.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check the status of the web application
log_message "Checking status of web application at $HEALTH_CHECK_URL..."
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$HEALTH_CHECK_URL")

if [ "$HTTP_STATUS" -eq 200 ]; then
    log_message "Web application is running. HTTP status: $HTTP_STATUS"
else
    log_message "Web application is down. HTTP status: $HTTP_STATUS. Attempting to restart..."

    # Restart the service on the remote server
    if ssh "$REMOTE_USER@$REMOTE_HOST" "sudo systemctl restart $SERVICE_NAME"; then
        log_message "Service $SERVICE_NAME restarted successfully."
    else
        log_message "Error: Failed to restart service $SERVICE_NAME."
        exit 1
    fi

    # Verify if the service is back up
    sleep 10  # Wait for the service to restart
    HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$HEALTH_CHECK_URL")
    if [ "$HTTP_STATUS" -eq 200 ]; then
        log_message "Web application is back up. HTTP status: $HTTP_STATUS"
    else
        log_message "Error: Web application is still down after restart. HTTP status: $HTTP_STATUS"
        exit 1
    fi
fi

log_message "Web application monitoring completed."

<< 'Comment'
Explanation:
REMOTE_USER: The username for the remote server.
REMOTE_HOST: The hostname or IP address of the remote server.
HEALTH_CHECK_URL: The URL of the web application's health check endpoint.
SERVICE_NAME: The name of the service to restart (e.g., webapp, nginx, apache2).
LOG_FILE: The path to the log file where the results will be stored.
curl: Checks the HTTP status of the web application's health endpoint.
ssh: Connects to the remote server and restarts the service using systemctl.
log_message: Logs messages with a timestamp to the specified log file.
Comment

#To run the script every 5 minutes, add the following line to your crontab:
*/5 * * * * /path/to/monitor_web_app.sh

<< 'comment'
Output:
If the web application is running:
2023-10-15 12:34:56 - Checking status of web application at http://localhost:8080/health...
2023-10-15 12:34:56 - Web application is running. HTTP status: 200
2023-10-15 12:34:56 - Web application monitoring completed.

If the web application is down and restarted:
2023-10-15 12:34:56 - Checking status of web application at http://localhost:8080/health...
2023-10-15 12:34:56 - Web application is down. HTTP status: 503. Attempting to restart...
2023-10-15 12:35:06 - Service webapp restarted successfully.
2023-10-15 12:35:06 - Web application is back up. HTTP status: 200
2023-10-15 12:35:06 - Web application monitoring completed.

If the web application is still down after restart:
2023-10-15 12:34:56 - Checking status of web application at http://localhost:8080/health...
2023-10-15 12:34:56 - Web application is down. HTTP status: 503. Attempting to restart...
2023-10-15 12:35:06 - Service webapp restarted successfully.
2023-10-15 12:35:06 - Error: Web application is still down after restart. HTTP status: 503
comment

#Add email notifications for alerts by integrating the mail command:
echo "Web application is down. HTTP status: $HTTP_STATUS" | mail -s "Web App Alert on $REMOTE_HOST" admin@example.com

