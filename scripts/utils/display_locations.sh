#!/bin/bash

# Display configured locations
echo "Configured locations:"
awk '{print NR ". " $0}' "$1"
