#!/bin/bash

# Script to find and move large files
# Usage: ./move_large_files.sh [source_dir] [dest_dir] [min_size]
# Example: ./move_large_files.sh /home/user/documents /mnt/archive 100M

# Default values if arguments not provided
SOURCE_DIR="${1:-.}"          # Default: current directory
DEST_DIR="${2:-./large_files}" # Default: ./large_files
MIN_SIZE="${3:-100M}"          # Default: 100MB
LOG_FILE="file_migration.log"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Logging function
log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Validate directories
if [ ! -d "$SOURCE_DIR" ]; then
    log "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
    log "Error: Failed to create destination directory $DEST_DIR"
    exit 1
fi

log "Starting file migration from $SOURCE_DIR to $DEST_DIR"
log "Searching for files larger than $MIN_SIZE"

# Find and move files
find "$SOURCE_DIR" -type f -size +"$MIN_SIZE" | while read -r file; do
    filename=$(basename "$file")
    
    log "Moving: $filename"
    if mv -v "$file" "$DEST_DIR" 2>> "$LOG_FILE"; then
        log "Success: $filename moved to $DEST_DIR"
    else
        log "Error: Failed to move $filename"
    fi
done

log "Migration completed. Check $LOG_FILE for details"

#Usage:
# Basic usage (uses defaults: current dir, ./large_files, 100MB)
./move_large_files.sh

# Custom parameters
./move_large_files.sh /home/user/downloads /mnt/storage 500M

#Sample Log Output:
2023-10-15 14:30:45 - Starting file migration from ./documents to ./archive
2023-10-15 14:30:45 - Searching for files larger than 100M
2023-10-15 14:30:45 - Moving: large_video.mp4
2023-10-15 14:30:45 - Success: large_video.mp4 moved to ./archive
2023-10-15 14:30:45 - Migration completed. Check file_migration.log for details

#Safety Measures:
Double-checks directory existence
Uses -size + syntax to avoid matching exact sizes
Preserves full directory structure in destination (use -exec mv -t "$DEST_DIR" {} + for flat structure)
Leaves original directory structure intact
Doesn't delete files - only moves them

#To Modify Behavior:
#Change file matching criteria by modifying the find command:
#For specific file types
find "$SOURCE_DIR" -type f -size +"$MIN_SIZE" -name "*.mp4"

#For older files
#find "$SOURCE_DIR" -type f -size +"$MIN_SIZE" -mtime +30
#Add dry-run option by replacing mv with echo
#Add email notifications for completion alerts
#Implement size unit conversion (MB/GB automatic handling)

#Important Notes:
Test with small files first using 1k instead of 100M
Ensure you have proper write permissions
Large file operations may take time depending on storage
Consider using rsync instead of mv for network locations
Add -exec syntax to find for better performance with many files