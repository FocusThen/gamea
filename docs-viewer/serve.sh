#!/bin/bash

# Simple script to serve the documentation viewer
# Usage: ./serve.sh [port]
# Note: This script should be run from the project root, not from docs-viewer/

PORT=${1:-8000}

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get project root (one level up from docs-viewer)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "Starting documentation viewer server..."
echo "Project root: $PROJECT_ROOT"
echo "Open http://localhost:$PORT/docs-viewer/ in your browser"
echo "Press Ctrl+C to stop"
echo ""

# Change to project root and start server
cd "$PROJECT_ROOT"

# Try different methods
if command -v python3 &> /dev/null; then
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    python -m SimpleHTTPServer $PORT
elif command -v php &> /dev/null; then
    php -S localhost:$PORT
else
    echo "Error: No suitable HTTP server found."
    echo "Please install Python 3, or use Node.js http-server"
    exit 1
fi

