#!/bin/bash

# Change to the Firebase directory
cd "$(dirname "$0")/../Firebase" || exit

# Run the Firebase command with all arguments passed to this script
firebase "$@" 