#!/bin/bash

echo "Stopping Ad Banner API server..."

# Find and kill the node process running server.js
PID=$(ps aux | grep "node server.js" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
    echo "No running server found"
    exit 1
fi

echo "Killing process $PID"
kill $PID

# Wait a moment and check if it's still running
sleep 2
if ps -p $PID > /dev/null 2>&1; then
    echo "Process still running, force killing..."
    kill -9 $PID
fi

echo "Server stopped successfully"