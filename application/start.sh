#!/bin/bash

# Set Node.js version
nvm use 18

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

echo "Starting Ad Banner API server..."
echo "Server will be available at http://localhost:3000"
echo "API endpoints:"
echo "  GET /health - Health check"
echo "  GET /api/banners - Get all banners"
echo "  GET /api/banners/:id - Get banner by ID"
echo ""
echo "Press Ctrl+C to stop the server"

npm start
