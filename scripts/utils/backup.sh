#!/bin/bash

# Define global variables and constants
BACKUP_TYPE="$2"
LINE_NUMBER="$3"
LOCATION_FILE="$4"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
HELP="./utils/help.sh"

function compress_and_log() {
    LOCATION=$1
    ALIEN_LOGS_DIR=$2
    FILE_LOCATION="${LOCATION%%:*}"
    FILE_PATH="${LOCATION#*:}"

    # Generate log for alien files
    ssh_command="cd $FILE_PATH && rm -f /tmp/*.log && for file in \$(find . -name '*.xyzar'); do
        timestamp=\"$(date +"%Y-%m-%d %H:%M:%S")\"
        server_source=\"$LOCATION\"
        tar -czvf \"\$file.tar.gz\" \"\$file\"
        original_size=\$(stat -c%s \"\$file\")
        compressed_size=\$(stat -c%s \"\$file.tar.gz\")
        echo \"File: \$(basename "\$file")\" >> \"/tmp/alien_file.log\"
        echo \"Timestamp: \$timestamp\" >> \"/tmp/alien_file.log\"
        echo \"Server Source: \$server_source\" >> \"/tmp/alien_file.log\"
        echo \"Original Size: \$original_size bytes\" >> \"/tmp/alien_file.log\"
        echo \"Compressed Size: \$compressed_size bytes\" >> \"/tmp/alien_file.log\"
        echo "" >> \"/tmp/alien_file.log\"
        done
       "

    # Execute the SSH command remotely
    ssh -n "$FILE_LOCATION" "$ssh_command" </dev/null

    # Check if there are log files at /tmp/*.log on the remote server
    if ssh "$FILE_LOCATION" "[ -f /tmp/*.log ]" </dev/null; then
        # If there are log files, move them to the local directory (main session)
        ssh "$FILE_LOCATION" "cat /tmp/*.log" >>"$ALIEN_LOGS_DIR/alien_file.log" </dev/null
    fi

}

function time_warp_log() {
    LOCATION=$1
    BACKUP_DIR=$2
    WARP_LOG_DIR=$3
    FILE_LOCATION="${LOCATION%%:*}"
    FILE_PATH="${LOCATION#*:}"

    # Create log of file timestamps
    ssh_command="cd $FILE_PATH && rm -f /tmp/*.log && for file in *; do
    if [ -f \"\$file\" ]; then
        access_time=\$(stat -c %x \"\$file\" | cut -d'.' -f1)
        modify_time=\$(stat -c %y \"\$file\" | cut -d'.' -f1)
        create_time=\$(stat -c %w \"\$file\" | cut -d'.' -f1)
        change_time=\$(stat -c %z \"\$file\" | cut -d'.' -f1)
        echo \"File: \$file\" >> \"/tmp/time_warp.log\"
        echo \"Access Time: \$access_time\" >> \"/tmp/time_warp.log\"
        echo \"Modify Time: \$modify_time\" >> \"/tmp/time_warp.log\"
        echo \"Change Time: \$change_time\" >> \"/tmp/time_warp.log\"
    fi
    done"

    # Execute the SSH command remotely
    ssh -n "$FILE_LOCATION" "$ssh_command" </dev/null

    # Move logs from remote server to local directory (main session)
    scp -q "$FILE_LOCATION:/tmp/*.log" "$BACKUP_DIR/$WARP_LOG_DIR/" </dev/null

}

function initiate_backup() {
    LOCATION=$(echo "$1" | tr -d '\r')
    user="${LOCATION%%@*}"
    FILE_LOCATION="${LOCATION%%:*}"
    FILE_PATH="${LOCATION#*:}"
    ALIEN_LOGS_DIR="../data/$user/alien_logs"
    WARP_LOG_DIR="./time_logs"

    # Define the backup directory path
    BACKUP_DIR="../data/$user/backups/backup_$TIMESTAMP"

    # Create the directories and parent directories if they don't exist
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$ALIEN_LOGS_DIR"
    mkdir -p "$BACKUP_DIR"/"$WARP_LOG_DIR"
    touch "$ALIEN_LOGS_DIR/alien_file.log"

    # Call the time_warp_log function to handle time warp information
    time_warp_log "$LOCATION" "$BACKUP_DIR" "$WARP_LOG_DIR"

    # Call the compress_and_log function to handle compression and logging
    compress_and_log "$LOCATION" "$ALIEN_LOGS_DIR"

    rsync -avz -q --progress --exclude='*.xyzar' "$LOCATION" "$BACKUP_DIR" </dev/null

    # Execute the SSH command remotely
    ssh "$FILE_LOCATION" "find \"$FILE_PATH\" -type f -name \"*.tar.gz\" -exec rm {} \\;" </dev/null

}

if [ "$BACKUP_TYPE" == "-L" ]; then
    # Backup a specific location by line number
    if [ -z "$LINE_NUMBER" ]; then
        echo "-B -L must be run with a line number"
        source $HELP
    else
        # Return specified location based on line number
        LOCATION=$(sed -n "${LINE_NUMBER}p" "$LOCATION_FILE")
        if [ -n "$LOCATION" ]; then
            echo "Initiating backup for location "$LOCATION"..."
            initiate_backup "$LOCATION"
        else
            # Use wc to count the number of lines in the .cfg file
            LINE_COUNT=$(wc -l <"$LOCATION_FILE")
            echo "Line $LINE_NUMBER not found in location.cfg"
            echo "Please choose a value between 1 and $LINE_COUNT"
        fi
    fi
else
    # Backup all locations
    echo "Initiating backups for all locations..."
    while read -r LOCATION; do
        echo "Backing up: $LOCATION"
        initiate_backup "$LOCATION"
    done <"$LOCATION_FILE"
fi
