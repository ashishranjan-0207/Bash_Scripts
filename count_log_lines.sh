#Shell script to count the number of lines in all log files in a specified directory. The script will recursively search for log files (files with a .log extension) and display the total number of lines for each file, as well as the overall total.

#!/bin/bash

# Variables
LOG_DIR="${1:-/var/log}"  # Directory to search for log files (default: /var/log)
TOTAL_LINES=0              # Variable to store the total number of lines

# Function to count lines in a file
count_lines() {
    local file="$1"
    local lines
    lines=$(wc -l < "$file")
    echo "$file: $lines lines"
    TOTAL_LINES=$((TOTAL_LINES + lines))
}

# Check if the directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory $LOG_DIR does not exist."
    exit 1
fi

# Find all .log files and count lines
echo "Counting lines in log files in $LOG_DIR..."
while IFS= read -r -d '' file; do
    count_lines "$file"
done < <(find "$LOG_DIR" -type f -name "*.log" -print0)

# Display the total number of lines
echo "-----------------------------------"
echo "Total lines in all log files: $TOTAL_LINES"

<< 'comment'
Explanation:
LOG_DIR: The directory to search for log files. Defaults to /var/log if no directory is provided as an argument.
TOTAL_LINES: A variable to accumulate the total number of lines across all log files.
count_lines: A function that counts the lines in a file using wc -l and updates the total line count.
find: Recursively searches for files with a .log extension in the specified directory.
wc -l: Counts the number of lines in a file.
while IFS= read -r -d '': Safely handles filenames with spaces or special characters.
comment

#The script only counts lines in files with a .log extension. If you want to include other file types (e.g., .txt), modify the find command:
find "$LOG_DIR" -type f \( -name "*.log" -o -name "*.txt" \) -print0

#If you want to exclude certain directories, use the -not -path option with find:
find "$LOG_DIR" -type f -name "*.log" -not -path "*/exclude_dir/*" -print0

<< 'comment'
Output Display:
Counting lines in log files in /var/log...
/var/log/syslog: 1500 lines
/var/log/auth.log: 300 lines
/var/log/nginx/access.log: 2500 lines
-----------------------------------
Total lines in all log files: 4300
comment
