#!/bin/bash

# Define global variables and constants
LOCATION_FILE="../configs/locations.cfg"

# Define global utility functions
DISPLAY_LOCATIONS="./utils/display_locations.sh"
BACKUP="./utils/backup.sh"
RESTORE="./utils/restore.sh"
HELP="./utils/help.sh"

# Main script logic
if [ $# -eq 0 ]; then
    # Display configured locations
    source $DISPLAY_LOCATIONS $LOCATION_FILE

elif [ "$1" == "-B" ]; then
    # Initiate backup function
    source $BACKUP "$1" "$2" "$3" $LOCATION_FILE

elif [ "$1" == "-R" ]; then
    # Initiate restore function
    source $RESTORE "$1" "$2" "$3" $LOCATION_FILE

elif [ "$1" == "-h" ]; then
    # Display usage instructions
    source $HELP

else
    # Handle invalid arguments
    echo "Invalid arguments."
    echo "Run with -h for list of valid commands"
fi
