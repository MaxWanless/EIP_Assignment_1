#!/bin/bash

# Display usage instructions

echo "Usage: $0 [OPTIONS]"
echo "OPTIONS:"
echo "                : Initiates backups for all locations."
echo "  -B            : Initiates backups for all locations."
echo "  -B -L n       : Initiates backup only for the specific location by line number n."
echo "  -R  n         : Restore the nth backup (from the most recent)."
echo "  -R -L n       : Restore the nth backup (from the most recent)."
echo "  -T            : Automatically adjust time-warped files during restore."
echo "  -h            : Display this help message."
