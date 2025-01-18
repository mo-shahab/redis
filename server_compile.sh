#!/bin/bash

# Create the bin directory if it doesn't exist
mkdir -p bin

# Compile the server code
g++ -Wall -Wextra -O2 -g server.cpp -o bin/server

# Check if compilation succeeded
if [ $? -eq 0 ]; then
    echo "Server compiled successfully. Executable is in bin/server"
else
    echo "Server compilation failed."
    exit 1
fi

