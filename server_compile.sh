#!/bin/bash

# Create the bin directory if it doesn't exist
mkdir -p bin

# First, let's see what files we have
echo "Available files:"
ls -la *.cpp *.h 2>/dev/null || echo "Some files missing"

# Compile all source files together
echo "Compiling server..."
g++ \
    server.cpp \
    hashtable.cpp \
    avl.cpp \
    heap.cpp \
    zset.cpp \
    thread_pool.cpp \
    -o bin/server

# Check if compilation succeeded
if [ $? -eq 0 ]; then
    echo "Server compiled successfully. Executable is in bin/server"
else
    echo "Server compilation failed."
    exit 1
fi
