#!/bin/bash

# Define global variables and constants
if [[ "$2" =~ ^[0-9]+$ ]]; then
    RESTORE_VERSION="$2"
else
    RESTORE_VERSION=1
fi
LINE_NUMBER="$3"
LOCATION_FILE="$4"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SHOW_USAGE="./utils/show_usage.sh"

function decompress_files() {
    LOCATION=$1
    FILE_LOCATION=$2
    FILE_PATH=$3

    SSH_COMMAND="cd $FILE_PATH && rm -f /tmp/*.log && for file in \$(find . -name '*.xyzar.tar.gz'); do
        tar -xzvf \"\$file\"
        rm -f \"\$file\"
        done
       "
    # Execute the SSH command remotely
    ssh -n "$FILE_LOCATION" "$SSH_COMMAND" </dev/null

}

function initiate_restore() {
    LOCATION=$(echo "$1" | tr -d '\r')
    USER="${LOCATION%%@*}"
    FILE_LOCATION="${LOCATION%%:*}"
    FILE_PATH="${LOCATION#*:}"
    BACKUP_FOLDER="../data/$USER/backups/"

    # List all backup folders for the user, sorted by modification time (most recent first)
    BACKUP_LIST=($(find $BACKUP_FOLDER -mindepth 1 -maxdepth 1 -type d -printf "%T@ %p\n" | sort -n -r | cut -d' ' -f2-))

    # Check if n exceeds the number of available backups
    if [ "$RESTORE_VERSION" -gt "${#BACKUP_LIST[@]}" ]; then
        echo "Invalid value of n. There are only ${#BACKUP_LIST[@]} backups available."
        exit 1
    fi

    echo "Restoring location: $LOCATION"
    echo "Restoring backup: $RESTORE_VERSION"

    # Select the backup folder to restore based on the -R n value
    SELECTED_BACKUP="${BACKUP_LIST[$((RESTORE_VERSION - 1))]}"

    ssh $FILE_LOCATION "rm -r -f $FILE_PATH*" </dev/null

    # Use rsync to restore the selected backup to the destination folder
    rsync -avz --progress -O --exclude='time_logs/' "$SELECTED_BACKUP/" "$LOCATION" </dev/null

    # Call the decompress_files function to handle decompression of files
    decompress_files "$LOCATION" "$FILE_LOCATION" "$FILE_PATH"

}

if [ "$2" == "-L" ]; then
    LINE_NUMBER="$3"
    # Backup a specific location by line number
    if [ -z "$LINE_NUMBER" ]; then
        echo "-R -L must be run with a location line number"
        source $SHOW_USAGE
    else
        # Return specified location based on line number
        LOCATION=$(sed -n "${LINE_NUMBER}p" "$LOCATION_FILE" | tr -d '\r')
        initiate_restore "$LOCATION"
    fi
else
    if [ -z "$2" ]; then
        echo "-R must be run with a backup number"
        source $SHOW_USAGE
    else
        # Check if n is a positive integer
        if [[ ! "$RESTORE_VERSION" =~ ^[1-9][0-9]*$ ]]; then
            echo "n must be a positive integer"
            exit 1
        fi
        echo "Initiating restoration for all locations..."
        while read -r LOCATION; do
            initiate_restore "$LOCATION"
        done <"$LOCATION_FILE"
    fi
fi
