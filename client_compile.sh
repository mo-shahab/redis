#!/bin/bash

# Create the bin directory if it doesn't exist
mkdir -p bin

# Compile the client code
g++ -Wall -Wextra -O2 -g client.cpp -o bin/client

# Check if compilation succeeded
if [ $? -eq 0 ]; then
    echo "Client compiled successfully. Executable is in bin/client"
else
    echo "Client compilation failed."
    exit 1
fi

