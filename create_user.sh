#!/bin/bash

# User Creation Script
# Usage: sudo ./create_user.sh <username> <password> <comma-separated-groups>
# Example: sudo ./create_user.sh john secret123 sudo,developers

LOG_FILE="/var/log/user_creation.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

# Check root privileges
if [[ $EUID -ne 0 ]]; then
    log "Error: This script must be run as root"
    exit 1
fi

# Validate arguments
if [[ $# -lt 3 ]]; then
    log "Usage: $0 <username> <password> <comma-separated-groups>"
    exit 1
fi

USERNAME="$1"
PASSWORD="$2"
GROUPS="$3"

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
    log "Error: User $USERNAME already exists"
    exit 1
fi

# Create user with home directory
if ! useradd -m "$USERNAME" -s /bin/bash; then
    log "Error: Failed to create user $USERNAME"
    exit 1
fi
log "Created user $USERNAME with home directory /home/$USERNAME"

# Set password
echo "$USERNAME:$PASSWORD" | chpasswd
if [[ $? -ne 0 ]]; then
    log "Error: Failed to set password for $USERNAME"
    exit 1
fi
log "Password set for $USERNAME"

# Process groups
IFS=',' read -ra GROUP_ARRAY <<< "$GROUPS"
for GROUP in "${GROUP_ARRAY[@]}"; do
    if getent group "$GROUP" >/dev/null; then
        usermod -aG "$GROUP" "$USERNAME"
        log "Added $USERNAME to group $GROUP"
    else
        log "Warning: Group $GROUP does not exist - skipping"
    fi
done

log "User creation completed successfully for $USERNAME"
exit 0

#Features:
#Creates user with home directory (/home/<username>)
#Sets default shell to bash
#Sets user password securely using chpasswd
#Adds user to specified groups
#Validates group existence before adding
#Comprehensive logging to /var/log/user_creation.log
#Error checking at each step
#Root privilege verification
#Security Considerations:
#Run with sudo for root privileges
#Passwords are passed as arguments (consider using SSH keys or a secure password prompt for production use)
#Sensitive information (passwords) not stored in logs

#Usage:
sudo ./create_user.sh <username> <password> <group1,group2,group3>

#Example:
sudo ./create_user.sh jane mySecurePass123 sudo,www-data,developers

#To Verify:
id jane
# Should show groups: sudo, www-data, developers
ls /home/jane
# Should show home directory contents

#Note: For production environments, consider:
#Using SSH keys instead of passwords
#Storing credentials in a secure vault
#Adding email/SMS notifications
#Implementing password complexity checks
#Using systemd services for automated management